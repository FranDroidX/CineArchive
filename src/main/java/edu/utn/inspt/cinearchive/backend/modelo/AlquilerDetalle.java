package edu.utn.inspt.cinearchive.backend.modelo;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class AlquilerDetalle {
    private Long id;
    private Long usuarioId;
    private Long contenidoId;
    private String tituloContenido;
    private String imagenUrlContenido;
    private LocalDateTime fechaInicio;
    private LocalDateTime fechaFin;
    private Integer periodoAlquiler;
    private BigDecimal precio;
    private Alquiler.Estado estado;
    private boolean visto;
    private long diasRestantes;
    private int progresoPct;
    private long segundosRestantes; // Para cálculo preciso de tiempo restante
    private boolean expirado; // Bandera para la UI

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUsuarioId() { return usuarioId; }
    public void setUsuarioId(Long usuarioId) { this.usuarioId = usuarioId; }
    public Long getContenidoId() { return contenidoId; }
    public void setContenidoId(Long contenidoId) { this.contenidoId = contenidoId; }
    public String getTituloContenido() { return tituloContenido; }
    public void setTituloContenido(String tituloContenido) { this.tituloContenido = tituloContenido; }
    public String getImagenUrlContenido() { return imagenUrlContenido; }
    public void setImagenUrlContenido(String imagenUrlContenido) { this.imagenUrlContenido = imagenUrlContenido; }
    public LocalDateTime getFechaInicio() { return fechaInicio; }
    public void setFechaInicio(LocalDateTime fechaInicio) { this.fechaInicio = fechaInicio; }
    public LocalDateTime getFechaFin() { return fechaFin; }
    public void setFechaFin(LocalDateTime fechaFin) { this.fechaFin = fechaFin; }
    public Integer getPeriodoAlquiler() { return periodoAlquiler; }
    public void setPeriodoAlquiler(Integer periodoAlquiler) { this.periodoAlquiler = periodoAlquiler; }
    public BigDecimal getPrecio() { return precio; }
    public void setPrecio(BigDecimal precio) { this.precio = precio; }
    public Alquiler.Estado getEstado() { return estado; }
    public void setEstado(Alquiler.Estado estado) { this.estado = estado; }
    public boolean isVisto() { return visto; }
    public void setVisto(boolean visto) { this.visto = visto; }
    public long getDiasRestantes() { return diasRestantes; }
    public void setDiasRestantes(long diasRestantes) { this.diasRestantes = diasRestantes; }
    public int getProgresoPct() { return progresoPct; }
    public void setProgresoPct(int progresoPct) { this.progresoPct = progresoPct; }
    public long getSegundosRestantes() { return segundosRestantes; }
    public void setSegundosRestantes(long segundosRestantes) { this.segundosRestantes = segundosRestantes; }
    public boolean isExpirado() { return expirado; }
    public void setExpirado(boolean expirado) { this.expirado = expirado; }
}
