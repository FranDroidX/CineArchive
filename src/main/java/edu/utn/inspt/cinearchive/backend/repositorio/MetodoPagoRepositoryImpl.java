package edu.utn.inspt.cinearchive.backend.repositorio;

import edu.utn.inspt.cinearchive.backend.modelo.MetodoPago;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.jdbc.support.KeyHolder;
import org.springframework.stereotype.Repository;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public class MetodoPagoRepositoryImpl implements MetodoPagoRepository {

    @Autowired
    private JdbcTemplate jdbcTemplate;

    private static final RowMapper<MetodoPago> METODO_PAGO_ROW_MAPPER = (rs, rowNum) -> {
        MetodoPago mp = new MetodoPago();
        mp.setId(rs.getLong("id"));
        mp.setUsuarioId(rs.getLong("usuario_id"));
        mp.setTipo(MetodoPago.Tipo.valueOf(rs.getString("tipo")));
        mp.setAlias(rs.getString("alias"));
        mp.setTitular(rs.getString("titular"));
        mp.setNumeroTarjeta(rs.getString("numero_tarjeta"));
        mp.setFechaVencimiento(rs.getString("fecha_vencimiento"));

        String tipoTarjetaStr = rs.getString("tipo_tarjeta");
        if (tipoTarjetaStr != null) {
            mp.setTipoTarjeta(MetodoPago.TipoTarjeta.valueOf(tipoTarjetaStr));
        }

        mp.setEmailPlataforma(rs.getString("email_plataforma"));
        mp.setPreferido(rs.getBoolean("preferido"));
        mp.setActivo(rs.getBoolean("activo"));

        Timestamp fechaCreacionTS = rs.getTimestamp("fecha_creacion");
        if (fechaCreacionTS != null) {
            mp.setFechaCreacion(fechaCreacionTS.toLocalDateTime());
        }

        return mp;
    };

    @Override
    public MetodoPago save(MetodoPago metodoPago) {
        String sql = "INSERT INTO metodo_pago (usuario_id, tipo, alias, titular, numero_tarjeta, " +
                     "fecha_vencimiento, tipo_tarjeta, email_plataforma, preferido, activo, fecha_creacion) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

        KeyHolder keyHolder = new GeneratedKeyHolder();

        jdbcTemplate.update(connection -> {
            PreparedStatement ps = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setLong(1, metodoPago.getUsuarioId());
            ps.setString(2, metodoPago.getTipo().name());
            ps.setString(3, metodoPago.getAlias());
            ps.setString(4, metodoPago.getTitular());
            ps.setString(5, metodoPago.getNumeroTarjeta());
            ps.setString(6, metodoPago.getFechaVencimiento());

            if (metodoPago.getTipoTarjeta() != null) {
                ps.setString(7, metodoPago.getTipoTarjeta().name());
            } else {
                ps.setNull(7, Types.VARCHAR);
            }

            ps.setString(8, metodoPago.getEmailPlataforma());
            ps.setBoolean(9, metodoPago.getPreferido() != null ? metodoPago.getPreferido() : false);
            ps.setBoolean(10, metodoPago.getActivo() != null ? metodoPago.getActivo() : true);
            ps.setTimestamp(11, Timestamp.valueOf(metodoPago.getFechaCreacion() != null ?
                metodoPago.getFechaCreacion() : LocalDateTime.now()));

            return ps;
        }, keyHolder);

        metodoPago.setId(keyHolder.getKey().longValue());
        return metodoPago;
    }

    @Override
    public MetodoPago update(MetodoPago metodoPago) {
        String sql = "UPDATE metodo_pago SET tipo = ?, alias = ?, titular = ?, numero_tarjeta = ?, " +
                     "fecha_vencimiento = ?, tipo_tarjeta = ?, email_plataforma = ?, preferido = ?, activo = ? " +
                     "WHERE id = ?";

        jdbcTemplate.update(sql,
            metodoPago.getTipo().name(),
            metodoPago.getAlias(),
            metodoPago.getTitular(),
            metodoPago.getNumeroTarjeta(),
            metodoPago.getFechaVencimiento(),
            metodoPago.getTipoTarjeta() != null ? metodoPago.getTipoTarjeta().name() : null,
            metodoPago.getEmailPlataforma(),
            metodoPago.getPreferido(),
            metodoPago.getActivo(),
            metodoPago.getId()
        );

        return metodoPago;
    }

    @Override
    public Optional<MetodoPago> findById(Long id) {
        String sql = "SELECT * FROM metodo_pago WHERE id = ?";
        try {
            MetodoPago mp = jdbcTemplate.queryForObject(sql, METODO_PAGO_ROW_MAPPER, id);
            return Optional.ofNullable(mp);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    @Override
    public List<MetodoPago> findByUsuarioId(Long usuarioId) {
        String sql = "SELECT * FROM metodo_pago WHERE usuario_id = ? ORDER BY preferido DESC, fecha_creacion DESC";
        return jdbcTemplate.query(sql, METODO_PAGO_ROW_MAPPER, usuarioId);
    }

    @Override
    public List<MetodoPago> findActiveByUsuarioId(Long usuarioId) {
        String sql = "SELECT * FROM metodo_pago WHERE usuario_id = ? AND activo = 1 " +
                     "ORDER BY preferido DESC, fecha_creacion DESC";
        return jdbcTemplate.query(sql, METODO_PAGO_ROW_MAPPER, usuarioId);
    }

    @Override
    public Optional<MetodoPago> findPreferidoByUsuarioId(Long usuarioId) {
        String sql = "SELECT * FROM metodo_pago WHERE usuario_id = ? AND preferido = 1 AND activo = 1";
        try {
            MetodoPago mp = jdbcTemplate.queryForObject(sql, METODO_PAGO_ROW_MAPPER, usuarioId);
            return Optional.ofNullable(mp);
        } catch (EmptyResultDataAccessException e) {
            return Optional.empty();
        }
    }

    @Override
    public boolean deactivate(Long id) {
        String sql = "UPDATE metodo_pago SET activo = 0 WHERE id = ?";
        int rows = jdbcTemplate.update(sql, id);
        return rows > 0;
    }

    @Override
    public boolean activate(Long id) {
        String sql = "UPDATE metodo_pago SET activo = 1 WHERE id = ?";
        int rows = jdbcTemplate.update(sql, id);
        return rows > 0;
    }

    @Override
    public boolean delete(Long id) {
        String sql = "DELETE FROM metodo_pago WHERE id = ?";
        int rows = jdbcTemplate.update(sql, id);
        return rows > 0;
    }

    @Override
    public boolean setPreferido(Long id, Long usuarioId) {
        // Primero desmarca todos como no preferidos
        String sql1 = "UPDATE metodo_pago SET preferido = 0 WHERE usuario_id = ?";
        jdbcTemplate.update(sql1, usuarioId);

        // Luego marca el seleccionado como preferido
        String sql2 = "UPDATE metodo_pago SET preferido = 1 WHERE id = ? AND usuario_id = ?";
        int rows = jdbcTemplate.update(sql2, id, usuarioId);
        return rows > 0;
    }
}

