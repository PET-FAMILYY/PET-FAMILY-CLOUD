package br.com.fiap.petfamily;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class PetFamilyApplication {

    public static void main(String[] args) {
        SpringApplication.run(PetFamilyApplication.class, args);
    }
}
