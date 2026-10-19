-- ============================================
-- INSERTAR INMUEBLES (PROPIEDADES)
-- ============================================

INSERT INTO inmuebles (id, titulo, tipo, ubicacion, precio, recamaras, banos, area, descripcion, asesor, activo, latitud, longitud, fotos, fecha_registro) VALUES
('inm_1', 'Hacienda San José Bondegui', 'Hacienda', 'Puebla', 418000000, 5, 4, 12700000, 'Hacienda histórica con 1,270 hectáreas en Puebla.', 'Willians Arturo Carrillo Tosca', true, 19.0414, -98.2063, '[]', '2026-10-15'),
('inm_2', 'Terreno frente al mar Caribe', 'Terreno', 'Cozumel, Quintana Roo', 150000000, 0, 0, 4700000, 'Terreno premium frente al mar Caribe con 4,700,000 m2.', 'Roberto Rodríguez', true, 20.5083, -86.9458, '[]', '2026-10-15'),
('inm_3', '5 Hectáreas en Manzanillo', 'Terreno', 'Manzanillo, Colima', 20000000, 0, 0, 50000, 'Terreno con vista al mar en zona de alto desarrollo.', 'Roberto Rodríguez', true, 19.0543, -104.3189, '[]', '2026-10-15'),
('inm_4', 'Oro - Arabia Saudita, Dubai', 'Mina', 'Dubai, UAE', 260000000, 0, 0, 100000, 'Terreno premium y operaciones de oro en Dubai.', 'Claudia Morales', true, 25.2048, 55.2708, '[]', '2026-10-15'),
('inm_5', 'Oro en lingotes Ernesto', 'Mina', 'Querétaro', 2489150000, 0, 0, 0, 'Proveedor mayoritario de minerales en México. Volumen en kg o toneladas. Se requiere carta LOI.', 'Alfredo Ruiz', true, 20.5888, -100.3899, '[]', '2026-10-16'),
('inm_6', 'Gasolinera en Pachuca', 'Gasolinera', 'Pachuca, Hidalgo', 53000000, 2, 2, 2000, 'Gasolinera sobre la avenida principal Las Palomas. 316,783 litros despachados mensuales.', 'Martín Flores', true, 20.1011, -98.7591, '[]', '2026-10-16'),
('inm_7', '25,000 Hectáreas Laguna de Términos', 'Terreno', 'Campeche', 1000000000, 0, 0, 250000000, 'Macro terreno de inversión en Laguna de Términos, Campeche.', 'Willians Arturo Carrillo Tosca', true, 18.4500, -92.2000, '[]', '2026-10-16');

-- Confirmar que se insertaron correctamente
SELECT COUNT(*) as total_inmuebles FROM inmuebles;