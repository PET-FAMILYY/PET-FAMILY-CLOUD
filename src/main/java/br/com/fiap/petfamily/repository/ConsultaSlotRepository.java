package br.com.fiap.petfamily.repository;

import br.com.fiap.petfamily.entity.ConsultaSlot;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ConsultaSlotRepository extends JpaRepository<ConsultaSlot, Long> {

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Query("DELETE FROM ConsultaSlot cs WHERE cs.consultaId = :consultaId")
    void deleteByConsultaId(@Param("consultaId") Long consultaId);
}
