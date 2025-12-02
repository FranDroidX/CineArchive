package edu.utn.inspt.cinearchive.frontend.controlador;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/home")
    public String index() {
        return "index"; // Esto resolverá a /WEB-INF/views/index.jsp
    }

    /**
     * Redirecciona la raíz / al login
     */
    @GetMapping("/")
    public String root() {
        return "redirect:/login";
    }

    /**
     * Redirecciona /cinearchive al login
     */
    @GetMapping("/cinearchive")
    public String cinearchive() {
        return "redirect:/login";
    }
}
