package com.rmls.middlelayer.service;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    private static final Logger logger = LoggerFactory.getLogger(WebSocketConfig.class);

    @Autowired
    private WebSocketHandlerService webSocketHandlerService;

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {

        logger.info("WebSocketConfig-registerWebSocketHandlers-Called");
        registry.addHandler(webSocketHandlerService, "/inverterwebsocket")
                .setAllowedOrigins("*");
        // .addInterceptors(new HandshakeInterceptor());
    }

    // @Override
    // public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {

    // logger.info("WebSocketConfig-registerWebSocketHandlers-Called");
    // registry.addHandler(webSocketHandlerService, "/rapidevwebsocket")
    // .setAllowedOrigins("*")
    // .addInterceptors(new HandshakeInterceptor());
    // }

    // @Component
    // public class HandshakeInterceptor implements
    // org.springframework.web.socket.server.HandshakeInterceptor {

    // @Override
    // public boolean beforeHandshake(ServerHttpRequest request, ServerHttpResponse
    // response,
    // WebSocketHandler wsHandler, Map<String, Object> attributes) throws Exception
    // {
    // logger.info("UpdateWebSocketConfig-beforeHandshake-Called");
    // String token = extractToken(request);
    // System.out.println(token);
    // return true;
    // }

    // @Override
    // public void afterHandshake(ServerHttpRequest request, ServerHttpResponse
    // response,
    // WebSocketHandler wsHandler, Exception exception) {
    // // Do nothing after handshake
    // }

    // private String extractToken(ServerHttpRequest request) {

    // logger.info("UpdateWebSocketConfig-extractToken-Called");
    // // Extract token from query parameters
    // String query = request.getURI().getRawQuery();

    // if (query != null) {
    // String[] queryParams = query.split("SSID=");
    // if (queryParams.length > 0) {
    // return queryParams[1];
    // }
    // }

    // return null;
    // }
    // }
}
