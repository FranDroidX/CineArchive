package edu.utn.inspt.cinearchive.backend.repositorio;

import edu.utn.inspt.cinearchive.backend.modelo.Resena;
import edu.utn.inspt.cinearchive.backend.modelo.Usuario;
import edu.utn.inspt.cinearchive.backend.modelo.Contenido;
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
import java.util.List;
import java.util.Optional;

/**
 * Implementación del repositorio para la entidad Reseña con JDBC Template
 */
@Repository
public class ResenaRepositoryImpl implements ResenaRepository {

    private JdbcTemplate jdbcTemplate;

    @Autowired
    public void setDataSource(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
    }

    private final RowMapper<Resena> resenaRowMapper = (rs, rowNum) -> {
        Resena resena = new Resena();
        resena.setId(rs.getLong("id"));

        // Cargar datos del usuario (id y nombre)
        Usuario usuario = new Usuario();
        usuario.setId(rs.getLong("usuario_id"));
        try {
            usuario.setNombre(rs.getString("usuario_nombre"));
        } catch (Exception e) {
            // Si no existe la columna usuario_nombre, ignorar
        }
        resena.setUsuario(usuario);

        Contenido contenido = new Contenido();
        contenido.setId(rs.getLong("contenido_id"));
        resena.setContenido(contenido);

        resena.setCalificacion(rs.getDouble("calificacion"));
        resena.setTitulo(rs.getString("titulo"));
        resena.setTexto(rs.getString("texto"));
        if (rs.getDate("fecha_creacion") != null) {
            resena.setFechaCreacion(rs.getDate("fecha_creacion").toLocalDate());
        }
        if (rs.getDate("fecha_modificacion") != null) {
            resena.setFechaModificacion(rs.getDate("fecha_modificacion").toLocalDate());
        }
        return resena;
    };

    public List<Resena> findAll() {
        return jdbcTemplate.query(
                "SELECT r.*, u.nombre as usuario_nombre FROM resena r " +
                "LEFT JOIN usuario u ON r.usuario_id = u.id " +
                "ORDER BY r.fecha_creacion DESC",
                resenaRowMapper
        );
    }

    public Optional<Resena> findById(Long id) {
        try {
            return Optional.ofNullable(jdbcTemplate.queryForObject(
                    "SELECT r.*, u.nombre as usuario_nombre FROM resena r " +
                    "LEFT JOIN usuario u ON r.usuario_id = u.id " +
                    "WHERE r.id = ?",
                    resenaRowMapper,
                    id
            ));
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    public List<Resena> findByUsuarioId(Long usuarioId) {
        return jdbcTemplate.query(
                "SELECT r.*, u.nombre as usuario_nombre FROM resena r " +
                "LEFT JOIN usuario u ON r.usuario_id = u.id " +
                "WHERE r.usuario_id = ? ORDER BY r.fecha_creacion DESC",
                resenaRowMapper,
                usuarioId
        );
    }

    public List<Resena> findByContenidoId(Long contenidoId) {
        return jdbcTemplate.query(
                "SELECT r.*, u.nombre as usuario_nombre FROM resena r " +
                "LEFT JOIN usuario u ON r.usuario_id = u.id " +
                "WHERE r.contenido_id = ? ORDER BY r.fecha_creacion DESC",
                resenaRowMapper,
                contenidoId
        );
    }

    public List<Resena> findByCalificacionGreaterThanEqual(Double calificacion) {
        return jdbcTemplate.query(
                "SELECT r.*, u.nombre as usuario_nombre FROM resena r " +
                "LEFT JOIN usuario u ON r.usuario_id = u.id " +
                "WHERE r.calificacion >= ? ORDER BY r.calificacion DESC",
                resenaRowMapper,
                calificacion
        );
    }

    public Double calcularCalificacionPromedio(Long contenidoId) {
        return jdbcTemplate.queryForObject(
                "SELECT AVG(calificacion) FROM resena WHERE contenido_id = ?",
                Double.class,
                contenidoId
        );
    }

    public List<Resena> findByUsuarioIdAndContenidoId(Long usuarioId, Long contenidoId) {
        return jdbcTemplate.query(
                "SELECT r.*, u.nombre as usuario_nombre FROM resena r " +
                "LEFT JOIN usuario u ON r.usuario_id = u.id " +
                "WHERE r.usuario_id = ? AND r.contenido_id = ?",
                resenaRowMapper,
                usuarioId,
                contenidoId
        );
    }

    public boolean existsByUsuarioIdAndContenidoId(Long usuarioId, Long contenidoId) {
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM resena WHERE usuario_id = ? AND contenido_id = ?",
                Integer.class,
                usuarioId,
                contenidoId
        );
        return count != null && count > 0;
    }

    public Resena save(Resena resena) {
        if (resena.getId() == null) {
            return insert(resena);
        }
        return update(resena);
    }

    private Resena insert(Resena resena) {
        KeyHolder keyHolder = new GeneratedKeyHolder();

        // Establecer fecha de creación si no está establecida
        if (resena.getFechaCreacion() == null) {
            resena.onCreate();
        }

        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(
                    "INSERT INTO resena (usuario_id, contenido_id, calificacion, titulo, texto, fecha_creacion) VALUES (?, ?, ?, ?, ?, ?)",
                    Statement.RETURN_GENERATED_KEYS
            );
            ps.setLong(1, resena.getUsuario().getId());
            ps.setLong(2, resena.getContenido().getId());
            ps.setDouble(3, resena.getCalificacion());
            ps.setString(4, resena.getTitulo());
            ps.setString(5, resena.getTexto());
            ps.setDate(6, java.sql.Date.valueOf(resena.getFechaCreacion()));
            return ps;
        }, keyHolder);

        resena.setId(keyHolder.getKey().longValue());
        return resena;
    }

    private Resena update(Resena resena) {
        // Establecer fecha de modificación
        resena.onUpdate();

        jdbcTemplate.update(
                "UPDATE resena SET calificacion = ?, titulo = ?, texto = ?, fecha_modificacion = ? WHERE id = ?",
                resena.getCalificacion(),
                resena.getTitulo(),
                resena.getTexto(),
                java.sql.Date.valueOf(resena.getFechaModificacion()),
                resena.getId()
        );
        return resena;
    }

    public void deleteById(Long id) {
        jdbcTemplate.update("DELETE FROM resena WHERE id = ?", id);
    }

    public boolean existsById(Long id) {
        Integer count = jdbcTemplate.queryForObject(
                "SELECT COUNT(*) FROM resena WHERE id = ?",
                Integer.class,
                id
        );
        return count != null && count > 0;
    }

    @Override
    public Double getPromedioCalificacionByContenidoId(Integer contenidoId) {
        String sql = "SELECT AVG(CAST(calificacion AS DECIMAL)) FROM resena WHERE contenido_id = ?";
        try {
            return jdbcTemplate.queryForObject(sql, Double.class, contenidoId);
        } catch (Exception e) {
            return 0.0;
        }
    }

    @Override
    public long countByContenidoId(Integer contenidoId) {
        String sql = "SELECT COUNT(*) FROM resena WHERE contenido_id = ?";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class, contenidoId);
        return count != null ? count : 0;
    }

    @Override
    public long count() {
        String sql = "SELECT COUNT(*) FROM resena";
        Integer count = jdbcTemplate.queryForObject(sql, Integer.class);
        return count != null ? count : 0;
    }

    // Implementación de métodos de la interfaz ResenaRepository (solo Integer IDs)

    @Override
    public Optional<Resena> findById(Integer id) {
        return findById(id.longValue());
    }

    @Override
    public List<Resena> findByUsuarioId(Integer usuarioId) {
        return findByUsuarioId(usuarioId.longValue());
    }

    @Override
    public List<Resena> findByContenidoId(Integer contenidoId) {
        return findByContenidoId(contenidoId.longValue());
    }

    @Override
    public List<Resena> findByCalificacion(Integer calificacion) {
        return findByCalificacionGreaterThanEqual(calificacion.doubleValue());
    }

    @Override
    public List<Resena> findByCalificacionRange(Integer minCalificacion, Integer maxCalificacion) {
        return jdbcTemplate.query(
                "SELECT * FROM resena WHERE calificacion >= ? AND calificacion <= ? ORDER BY calificacion DESC",
                resenaRowMapper,
                minCalificacion,
                maxCalificacion
        );
    }

    @Override
    public Optional<Resena> findByUsuarioIdAndContenidoId(Integer usuarioId, Integer contenidoId) {
        List<Resena> resenas = findByUsuarioIdAndContenidoId(usuarioId.longValue(), contenidoId.longValue());
        return resenas.isEmpty() ? Optional.empty() : Optional.of(resenas.get(0));
    }

    // save ya está implementado arriba

    @Override
    public void deleteById(Integer id) {
        deleteById(id.longValue());
    }

    @Override
    public boolean existsByUsuarioIdAndContenidoId(Integer usuarioId, Integer contenidoId) {
        return existsByUsuarioIdAndContenidoId(usuarioId.longValue(), contenidoId.longValue());
    }

    @Override
    public boolean existsById(Integer id) {
        return existsById(id.longValue());
    }
}
