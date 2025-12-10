package edu.utn.inspt.cinearchive.backend.repositorio;

import edu.utn.inspt.cinearchive.backend.modelo.Reporte;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Implementación del repositorio para la entidad Reporte con JDBC Template
 * Incluye queries complejas para analytics y reportes
 */
@Repository
public class ReporteRepositoryImpl implements ReporteRepository {

    private JdbcTemplate jdbcTemplate;

    @Autowired
    public void setDataSource(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    private final RowMapper<Reporte> reporteRowMapper = (rs, rowNum) -> {
        Reporte reporte = new Reporte();
        reporte.setId(rs.getInt("id"));
        reporte.setAnalistaId(rs.getInt("analista_id"));
        reporte.setTitulo(rs.getString("titulo"));
        reporte.setDescripcion(rs.getString("descripcion"));
        reporte.setTipoReporte(Reporte.TipoReporte.valueOf(rs.getString("tipo_reporte")));
        reporte.setParametros(rs.getString("parametros"));
        reporte.setResultados(rs.getString("resultados"));
        if (rs.getDate("fecha_generacion") != null) {
            reporte.setFechaGeneracion(rs.getDate("fecha_generacion").toLocalDate());
        }
        if (rs.getDate("periodo_inicio") != null) {
            reporte.setPeriodoInicio(rs.getDate("periodo_inicio").toLocalDate());
        }
        if (rs.getDate("periodo_fin") != null) {
            reporte.setPeriodoFin(rs.getDate("periodo_fin").toLocalDate());
        }
        return reporte;
    };

    // ==================== CRUD BÁSICO ====================

    public List<Reporte> findAll() {
        return jdbcTemplate.query(
                "SELECT * FROM reporte ORDER BY fecha_generacion DESC",
                reporteRowMapper
        );
    }

    public Optional<Reporte> findById(Integer id) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    "SELECT * FROM reporte WHERE id = ?",
                    reporteRowMapper,
                    id
            ));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }


    public Reporte save(Reporte reporte) {
        if (reporte.getId() == 0) {
            return insert(reporte);
        }
        return update(reporte);
    }

    private Reporte insert(Reporte reporte) {
        KeyHolder keyHolder = new GeneratedKeyHolder();

        // Establecer fecha de generación si no está establecida
        if (reporte.getFechaGeneracion() == null) {
            reporte.setFechaGeneracion(LocalDate.now());
        }

        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(
                    "INSERT INTO reporte (analista_id, titulo, descripcion, tipo_reporte, parametros, " +
                    "resultados, fecha_generacion, periodo_inicio, periodo_fin) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS
            );
            ps.setInt(1, reporte.getAnalistaId());
            ps.setString(2, reporte.getTitulo());
            ps.setString(3, reporte.getDescripcion());
            ps.setString(4, reporte.getTipoReporte().name());
            ps.setString(5, reporte.getParametros());
            ps.setString(6, reporte.getResultados());
            ps.setDate(7, java.sql.Date.valueOf(reporte.getFechaGeneracion()));
            if (reporte.getPeriodoInicio() != null) {
                ps.setDate(8, java.sql.Date.valueOf(reporte.getPeriodoInicio()));
            } else {
                ps.setNull(8, java.sql.Types.DATE);
            }
            if (reporte.getPeriodoFin() != null) {
                ps.setDate(9, java.sql.Date.valueOf(reporte.getPeriodoFin()));
            } else {
                ps.setNull(9, java.sql.Types.DATE);
            }
            return ps;
        }, keyHolder);

        reporte.setId(keyHolder.getKey().intValue());
        return reporte;
    }

    private Reporte update(Reporte reporte) {
        jdbcTemplate.update(
                "UPDATE reporte SET titulo = ?, descripcion = ?, parametros = ?, resultados = ?, " +
                "periodo_inicio = ?, periodo_fin = ? WHERE id = ?",
                reporte.getTitulo(),
                reporte.getDescripcion(),
                reporte.getParametros(),
                reporte.getResultados(),
                reporte.getPeriodoInicio(),
                reporte.getPeriodoFin(),
                reporte.getId()
        );
        return reporte;
    }

    public void deleteById(Integer id) {
        jdbcTemplate.update("DELETE FROM reporte WHERE id = ?", id);
    }

    public boolean existsById(Integer id) {
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM reporte WHERE id = ?",
                Integer.class,
                id
        );
        return count != null && count > 0;
    }

    // ==================== QUERIES COMPLEJAS PARA ANALYTICS ====================

    /**
     * Obtiene los contenidos más alquilados en un período
     * CORREGIDO: Filtro de fecha en el JOIN para contar solo alquileres del período
     */
    public List<Map<String, Object>> obtenerContenidosMasAlquilados(LocalDate fechaInicio, LocalDate fechaFin, int limite) {
        return jdbcTemplate.queryForList(
                "SELECT c.id, c.titulo, c.tipo, c.genero, COUNT(a.id) as total_alquileres, " +
                "AVG(r.calificacion) as calificacion_promedio " +
                "FROM contenido c " +
                "LEFT JOIN alquiler a ON c.id = a.contenido_id AND a.fecha_inicio BETWEEN ? AND ? " +
                "LEFT JOIN resena r ON c.id = r.contenido_id " +
                "WHERE a.id IS NOT NULL " +
                "GROUP BY c.id, c.titulo, c.tipo, c.genero " +
                "ORDER BY total_alquileres DESC " +
                "LIMIT ?",
                fechaInicio, fechaFin, limite
        );
    }


    /**
     * Estadísticas generales del sistema
     */
    public Map<String, Object> obtenerEstadisticasGenerales() {
        return jdbcTemplate.queryForMap(
                "SELECT " +
                "(SELECT COUNT(*) FROM contenido) as total_contenidos, " +
                "(SELECT COUNT(*) FROM contenido WHERE disponible_para_alquiler = true) as contenidos_disponibles, " +
                "(SELECT COUNT(*) FROM usuario) as total_usuarios, " +
                "(SELECT COUNT(*) FROM alquiler) as total_alquileres, " +
                "(SELECT COUNT(*) FROM resena) as total_resenas, " +
                "(SELECT AVG(calificacion) FROM resena) as calificacion_promedio_global, " +
                "(SELECT SUM(precio) FROM alquiler) as ingresos_totales"
        );
    }

    /**
     * Top categorías más populares
     */
    public List<Map<String, Object>> obtenerCategoriasPopulares(int limite) {
        return jdbcTemplate.queryForList(
                "SELECT cat.id, cat.nombre, cat.tipo, " +
                "COUNT(a.id) as total_alquileres " +
                "FROM categoria cat " +
                "INNER JOIN contenido_categoria cc ON cat.id = cc.categoria_id " +
                "INNER JOIN contenido c ON cc.contenido_id = c.id " +
                "INNER JOIN alquiler a ON c.id = a.contenido_id " +
                "GROUP BY cat.id, cat.nombre, cat.tipo " +
                "ORDER BY total_alquileres DESC " +
                "LIMIT ?",
                limite
        );
    }
}

