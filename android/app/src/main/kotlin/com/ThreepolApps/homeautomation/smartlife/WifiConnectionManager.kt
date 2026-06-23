package com.ThreepolApps.homeautomation.smartlife

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.net.NetworkRequest
import android.net.wifi.WifiConfiguration
import android.net.wifi.WifiManager
import android.net.wifi.WifiNetworkSpecifier
import android.net.wifi.WifiNetworkSuggestion
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.RequiresApi

class WifiConnectionManager(private val context: Context) {
    private val TAG = "WifiConnectionManager"
    private val connectivityManager = context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
    private val wifiManager = context.applicationContext.getSystemService(Context.WIFI_SERVICE) as WifiManager

    private var currentNetwork: Network? = null
    private var networkCallback: ConnectivityManager.NetworkCallback? = null
    private val handler = Handler(Looper.getMainLooper())
    private var connectionTimeoutRunnable: Runnable? = null

    fun connectToWifi(
        ssid: String,
        password: String,
        onSuccess: (String) -> Unit,
        onFailure: (String) -> Unit
    ) {
        Log.d(TAG, "Attempting to connect to WiFi: $ssid (Android ${Build.VERSION.SDK_INT})")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            // Android 10+ (API 29+) - Use both Suggestion + Specifier for maximum compatibility
            connectUsingCombinedApproach(ssid, password, onSuccess, onFailure)
        } else {
            // Android 9 and below (API 28 and below)
            connectLegacy(ssid, password, onSuccess, onFailure)
        }
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun connectUsingCombinedApproach(
        ssid: String,
        password: String,
        onSuccess: (String) -> Unit,
        onFailure: (String) -> Unit
    ) {
        Log.d(TAG, "Using combined approach: Suggestion + Specifier for $ssid")

        // First, add network suggestion for persistent connection
        addNetworkSuggestion(ssid, password)

        // Then use network specifier to force immediate connection
        connectUsingNetworkRequest(ssid, password, onSuccess, onFailure)
    }

    @RequiresApi(Build.VERSION_CODES.Q)
    private fun addNetworkSuggestion(ssid: String, password: String) {
        try {
            // Remove any existing suggestions first
            wifiManager.removeNetworkSuggestions(emptyList())

            val suggestionBuilder = WifiNetworkSuggestion.Builder()
                .setSsid(ssid)
                .setIsAppInteractionRequired(false) // Don't require user approval
                .setIsEnhancedOpen(false)

            if (password.isNotEmpty()) {
                suggestionBuilder.setWpa2Passphrase(password)
            }

            val suggestion = suggestionBuilder.build()
            val suggestions = listOf(suggestion)

            val status = wifiManager.addNetworkSuggestions(suggestions)

            when (status) {
                WifiManager.STATUS_NETWORK_SUGGESTIONS_SUCCESS -> {
                    Log.d(TAG, "Network suggestion added successfully")
                }
                WifiManager.STATUS_NETWORK_SUGGESTIONS_ERROR_ADD_DUPLICATE -> {
                    Log.d(TAG, "Network suggestion already exists (duplicate)")
                }
                else -> {
                    Log.w(TAG, "Failed to add network suggestion: $status")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error adding network suggestion: ${e.message}", e)
        }
    }

    private fun connectUsingNetworkRequest(
        ssid: String,
        password: String,
        onSuccess: (String) -> Unit,
        onFailure: (String) -> Unit
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.Q) {
            onFailure("Network request API not available on this Android version")
            return
        }

        // Clean up any existing connection
        disconnectWifi()

        try {
            // Flag to ensure we only call the callback once
            var callbackInvoked = false

            // Build WiFi network specifier
            val specifierBuilder = WifiNetworkSpecifier.Builder()
                .setSsid(ssid)

            // Add password if network is secured
            if (password.isNotEmpty()) {
                specifierBuilder.setWpa2Passphrase(password)
            }

            val wifiNetworkSpecifier = specifierBuilder.build()

            // Build network request with aggressive settings
            val networkRequest = NetworkRequest.Builder()
                .addTransportType(NetworkCapabilities.TRANSPORT_WIFI)
                .removeCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET) // Don't require internet
                .removeCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED) // Don't require validation
                .addCapability(NetworkCapabilities.NET_CAPABILITY_NOT_RESTRICTED)
                .setNetworkSpecifier(wifiNetworkSpecifier)
                .build()

            Log.d(TAG, "Network request created for SSID: $ssid")

            // Set connection timeout (45 seconds - increased for difficult networks)
            connectionTimeoutRunnable = Runnable {
                if (!callbackInvoked) {
                    Log.e(TAG, "Connection timeout for SSID: $ssid")
                    callbackInvoked = true
                    disconnectWifi()
                    onFailure("Connection timeout")
                }
            }
            handler.postDelayed(connectionTimeoutRunnable!!, 45000)

            // Create network callback
            networkCallback = object : ConnectivityManager.NetworkCallback() {
                override fun onAvailable(network: Network) {
                    super.onAvailable(network)
                    Log.d(TAG, "✅ Network available: $network")
//                    connectivityManager.bindProcessToNetwork(network)
                    if (callbackInvoked) {
                        Log.w(TAG, "Callback already invoked, but re-binding to network")
                        // Re-bind to the network even if we already invoked the callback
                        // This is crucial to maintain connection after validation
                        currentNetwork = network
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            connectivityManager.bindProcessToNetwork(network)
                        } else {
                            ConnectivityManager.setProcessDefaultNetwork(network)
                        }
                        return
                    }

                    // Cancel timeout - connection succeeded
                    connectionTimeoutRunnable?.let { handler.removeCallbacks(it) }
                    connectionTimeoutRunnable = null

                    // Bind process to this network IMMEDIATELY
                    currentNetwork = network
                    val bindResult = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        connectivityManager.bindProcessToNetwork(network)
                    } else {
                        ConnectivityManager.setProcessDefaultNetwork(network)
                    }

                    if (bindResult) {
                        Log.d(TAG, "✅ Successfully bound process to network: $ssid")
                        Log.d(TAG, "🔒 Network request ACTIVE - connection will persist")
                        callbackInvoked = true
                        onSuccess("Connected to $ssid")
                    } else {
                        Log.e(TAG, "❌ Failed to bind process to network")
                        callbackInvoked = true
                        disconnectWifi()
                        onFailure("Failed to bind to network")
                    }
                }

                override fun onUnavailable() {
                    super.onUnavailable()

                    if (callbackInvoked) {
                        Log.w(TAG, "Callback already invoked, ignoring onUnavailable")
                        return
                    }

                    Log.e(TAG, "❌ Network unavailable")

                    // Cancel timeout
                    connectionTimeoutRunnable?.let { handler.removeCallbacks(it) }
                    connectionTimeoutRunnable = null

                    callbackInvoked = true
                    disconnectWifi()
                    onFailure("Network unavailable")
                }

                override fun onLost(network: Network) {
                    super.onLost(network)
                    Log.w(TAG, "⚠️ Network lost: $network - attempting to maintain connection")

                    if (currentNetwork == network) {
                        Log.w(TAG, "Lost connection to bound network - this should not happen!")
                        Log.w(TAG, "Android may have dropped the network - trying to keep callback active")
                        // DON'T clear currentNetwork or unbind
                        // Keep the callback registered to try to reconnect
                        // currentNetwork = null
                    }
                }

                override fun onCapabilitiesChanged(
                    network: Network,
                    networkCapabilities: NetworkCapabilities
                ) {
                    super.onCapabilitiesChanged(network, networkCapabilities)
                    val hasInternet = networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_INTERNET)
                    val validated = networkCapabilities.hasCapability(NetworkCapabilities.NET_CAPABILITY_VALIDATED)
                    Log.d(TAG, "📡 Network capabilities - Internet: $hasInternet, Validated: $validated")

                    // CRITICAL: Re-bind the network when capabilities change
                    // This prevents Android from dropping the connection after validation fails
                    if (currentNetwork == network && callbackInvoked) {
                        Log.d(TAG, "🔄 Re-binding process to network to maintain connection")
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            val rebound = connectivityManager.bindProcessToNetwork(network)
                            Log.d(TAG, "Re-bind result: $rebound")
                        } else {
                            ConnectivityManager.setProcessDefaultNetwork(network)
                        }
                    }
                }

                override fun onLosing(network: Network, maxMsToLive: Int) {
                    super.onLosing(network, maxMsToLive)
                    Log.w(TAG, "⚠️ Network losing in ${maxMsToLive}ms - attempting to keep alive")

                    // Try to prevent the loss by re-binding
                    if (currentNetwork == network) {
                        Log.d(TAG, "🔄 Re-binding to prevent network loss")
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                            connectivityManager.bindProcessToNetwork(network)
                        } else {
                            ConnectivityManager.setProcessDefaultNetwork(network)
                        }
                    }
                }
            }

            // Request network - THIS STAYS ACTIVE
            connectivityManager.requestNetwork(networkRequest, networkCallback!!)
            Log.d(TAG, "🚀 Network request initiated - binding to $ssid")

        } catch (e: Exception) {
            Log.e(TAG, "❌ Error connecting to WiFi: ${e.message}", e)
            connectionTimeoutRunnable?.let { handler.removeCallbacks(it) }
            connectionTimeoutRunnable = null
            disconnectWifi()
            onFailure("Error: ${e.message}")
        }
    }

    private fun connectLegacy(
        ssid: String,
        password: String,
        onSuccess: (String) -> Unit,
        onFailure: (String) -> Unit
    ) {
        try {
            val wifiConfig = WifiConfiguration()
            wifiConfig.SSID = "\"$ssid\""

            if (password.isEmpty()) {
                wifiConfig.allowedKeyManagement.set(WifiConfiguration.KeyMgmt.NONE)
            } else {
                wifiConfig.preSharedKey = "\"$password\""
            }

            // Remove existing configuration with same SSID
            val configuredNetworks = wifiManager.configuredNetworks
            configuredNetworks?.forEach { config ->
                if (config.SSID == wifiConfig.SSID) {
                    wifiManager.removeNetwork(config.networkId)
                }
            }

            val netId = wifiManager.addNetwork(wifiConfig)

            if (netId == -1) {
                onFailure("Failed to add network configuration")
                return
            }

            wifiManager.disconnect()
            val enableResult = wifiManager.enableNetwork(netId, true)
            val reconnectResult = wifiManager.reconnect()

            if (enableResult && reconnectResult) {
                handler.postDelayed({
                    val connectionInfo = wifiManager.connectionInfo
                    if (connectionInfo != null && connectionInfo.ssid.replace("\"", "") == ssid) {
                        onSuccess("Connected to $ssid")
                    } else {
                        onFailure("Connection verification failed")
                    }
                }, 3000)
            } else {
                onFailure("Failed to enable or reconnect to network")
            }

        } catch (e: Exception) {
            Log.e(TAG, "Legacy connection error: ${e.message}", e)
            onFailure("Error: ${e.message}")
        }
    }

    fun disconnectWifi() {
        Log.d(TAG, "🔌 Disconnecting WiFi")

        // Cancel timeout
        connectionTimeoutRunnable?.let { handler.removeCallbacks(it) }
        connectionTimeoutRunnable = null

        // Unregister network callback
        try {
            networkCallback?.let {
                connectivityManager.unregisterNetworkCallback(it)
                networkCallback = null
                Log.d(TAG, "Network callback unregistered")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error unregistering callback: ${e.message}")
        }

        // Unbind process from network
        try {
            if (currentNetwork != null) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    connectivityManager.bindProcessToNetwork(null)
                } else {
                    ConnectivityManager.setProcessDefaultNetwork(null)
                }
                currentNetwork = null
                Log.d(TAG, "Process unbound from network")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error unbinding network: ${e.message}")
        }

        // Remove network suggestions (Android 10+)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            try {
                wifiManager.removeNetworkSuggestions(emptyList())
                Log.d(TAG, "Network suggestions removed")
            } catch (e: Exception) {
                Log.e(TAG, "Error removing suggestions: ${e.message}")
            }
        }
    }

    fun getCurrentSSID(): String? {
        return try {
            val connectionInfo = wifiManager.connectionInfo
            connectionInfo?.ssid?.replace("\"", "")
        } catch (e: Exception) {
            Log.e(TAG, "Error getting current SSID: ${e.message}")
            null
        }
    }

    fun isConnected(): Boolean {
        return try {
            val connectionInfo = wifiManager.connectionInfo
            connectionInfo != null && connectionInfo.ssid != null && connectionInfo.ssid != "<unknown ssid>"
        } catch (e: Exception) {
            Log.e(TAG, "Error checking connection: ${e.message}")
            false
        }
    }
}
