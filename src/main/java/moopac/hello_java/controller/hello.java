package moopac.hello_java.controller;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class hello {

    @GetMapping("hello")
    public String hello() {
            System.out.println("woshilog");


        return "hello world;";
    }


}


