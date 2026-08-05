package com.rmls.middlelayer.model;

public class MessageResponse {

    private String message;
    private Integer id;

    public MessageResponse(String message, Integer id) {
        this.message = message;
        this.id = id;
    }

    public MessageResponse(String message) {
        this.message = message;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    
   
}