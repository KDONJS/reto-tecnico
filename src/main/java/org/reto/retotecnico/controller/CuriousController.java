package org.reto.retotecnico.controller;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Random;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("/api")
public class CuriousController {
    private final List<String> curiousFacts = List.of(
            "¿Sabías que los pulpos tienen tres corazones?",
            "La miel nunca se echa a perder, se han encontrado tarros de miel de hace miles de años en perfecto estado.",
            "El corazón de un camarón está en su cabeza.",
            "Los Koalas tienen huellas dactilares muy parecidas a las de los humanos.",
            "Un rayo puede calentar el aire a su alrededor a temperaturas cinco veces superiores a las de la superficie del sol."
    );

    @GetMapping("/curioso")
    public String getCuriousFact() {
        Random random = new Random();
        int index = random.nextInt(curiousFacts.size());
        return curiousFacts.get(index);
    }
}
