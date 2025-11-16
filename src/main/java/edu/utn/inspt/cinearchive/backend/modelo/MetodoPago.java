package edu.utn.inspt.cinearchive.backend.modelo;

import java.io.Serializable;
import java.time.LocalDateTime;
import java.util.Objects;
import javax.validation.constraints.NotBlank;
import javax.validation.constraints.NotNull;
import javax.validation.constraints.Size;

public class MetodoPago implements Serializable {

    public enum Tipo {
        TARJETA_CREDITO,
        TARJETA_DEBITO,
        MERCADOPAGO,
        PAYPAL,
        TRANSFERENCIA,
        EFECTIVO
    }

    public enum TipoTarjeta {
        VISA,
        MASTERCARD,
        AMEX,
        OTRO
    }

    private Long id;

    @NotNull
    private Long usuarioId;

    @NotNull
    private Tipo tipo;

    @NotBlank
    @Size(max = 100)
    private String alias;

    @Size(max = 255)
    private String titular;

    @Size(max = 4)
    private String numeroTarjeta; // Últimos 4 dígitos

    @Size(max = 7)
    private String fechaVencimiento; // Formato MM/YYYY

    private TipoTarjeta tipoTarjeta;

    @Size(max = 255)
    private String emailPlataforma; // Para MercadoPago, PayPal, etc.

    private Boolean preferido;
    private Boolean activo;
    private LocalDateTime fechaCreacion;

    public MetodoPago() {
        this.preferido = false;
        this.activo = true;
        this.fechaCreacion = LocalDateTime.now();
    }

    // Getters y Setters

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Long getUsuarioId() {
        return usuarioId;
    }

    public void setUsuarioId(Long usuarioId) {
        this.usuarioId = usuarioId;
    }

    public Tipo getTipo() {
        return tipo;
    }

    public void setTipo(Tipo tipo) {
        this.tipo = tipo;
    }

    public String getAlias() {
        return alias;
    }

    public void setAlias(String alias) {
        this.alias = alias;
    }

    public String getTitular() {
        return titular;
    }

    public void setTitular(String titular) {
        this.titular = titular;
    }

    public String getNumeroTarjeta() {
        return numeroTarjeta;
    }

    public void setNumeroTarjeta(String numeroTarjeta) {
        this.numeroTarjeta = numeroTarjeta;
    }

    public String getFechaVencimiento() {
        return fechaVencimiento;
    }

    public void setFechaVencimiento(String fechaVencimiento) {
        this.fechaVencimiento = fechaVencimiento;
    }

    public TipoTarjeta getTipoTarjeta() {
        return tipoTarjeta;
    }

    public void setTipoTarjeta(TipoTarjeta tipoTarjeta) {
        this.tipoTarjeta = tipoTarjeta;
    }

    public String getEmailPlataforma() {
        return emailPlataforma;
    }

    public void setEmailPlataforma(String emailPlataforma) {
        this.emailPlataforma = emailPlataforma;
    }

    public Boolean getPreferido() {
        return preferido;
    }

    public void setPreferido(Boolean preferido) {
        this.preferido = preferido;
    }

    public Boolean getActivo() {
        return activo;
    }

    public void setActivo(Boolean activo) {
        this.activo = activo;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public void setFechaCreacion(LocalDateTime fechaCreacion) {
        this.fechaCreacion = fechaCreacion;
    }

    // Métodos de utilidad

    public String getDescripcion() {
        StringBuilder desc = new StringBuilder();
        desc.append(alias);

        if (tipo == Tipo.TARJETA_CREDITO || tipo == Tipo.TARJETA_DEBITO) {
            if (tipoTarjeta != null) {
                desc.append(" - ").append(tipoTarjeta.name());
            }
            if (numeroTarjeta != null && !numeroTarjeta.isEmpty()) {
                desc.append(" **** ").append(numeroTarjeta);
            }
        } else if (emailPlataforma != null && !emailPlataforma.isEmpty()) {
            desc.append(" (").append(emailPlataforma).append(")");
        }

        return desc.toString();
    }

    public boolean esTarjeta() {
        return tipo == Tipo.TARJETA_CREDITO || tipo == Tipo.TARJETA_DEBITO;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof MetodoPago)) return false;
        MetodoPago that = (MetodoPago) o;
        return Objects.equals(getId(), that.getId());
    }

    @Override
    public int hashCode() {
        return Objects.hash(getId());
    }

    @Override
    public String toString() {
        return "MetodoPago{" +
                "id=" + id +
                ", usuarioId=" + usuarioId +
                ", tipo=" + tipo +
                ", alias='" + alias + '\'' +
                ", preferido=" + preferido +
                ", activo=" + activo +
                '}';
    }
}

