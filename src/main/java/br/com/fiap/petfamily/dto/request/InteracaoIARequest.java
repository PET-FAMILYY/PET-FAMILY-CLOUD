package br.com.fiap.petfamily.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class InteracaoIARequest {

    @NotBlank(message = "Pergunta é obrigatória")
    private String pergunta;

    private String categoria;

    @NotNull(message = "ID do pet é obrigatório")
    private Long petId;
}
