package com.luck.login;

import com.sun.org.apache.xpath.internal.functions.FuncFalse;

public class LoginController {
    public boolean login(String userInfo){
        boolean result=false;
       if(userInfo!=null){
           result=true;
       }
        return  result;
    }


}
