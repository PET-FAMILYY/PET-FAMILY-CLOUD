package br.com.fiap.petfamily.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Pet Family API")
                        .description(
                            "API RESTful para acompanhamento contínuo da saúde dos pets. " +
                            "Desenvolvida como parte do Challenge CLYVO VET 2026 — FIAP.\n\n" +
                            "**Funcionalidades:**\n" +
                            "- Cadastro de tutores e pets\n" +
                            "- Registro de consultas veterinárias\n" +
                            "- Lembretes preventivos\n" +
                            "- Assistente de IA simulada para saúde animal\n" +
                            "- Dashboard com KPIs clínicos"
                        )
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("Pedro Vaz & João Victor")
                                .email("pedrovazferreira10@gmail.com"))
                        .license(new License()
                                .name("FIAP — Challenge CLYVO VET 2026")));
    }
}
