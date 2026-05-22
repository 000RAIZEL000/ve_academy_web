-- Script para crear la base de datos de VE Academy en MySQL (XAMPP)
-- Ejecutar en phpMyAdmin o en la consola MySQL de XAMPP

CREATE DATABASE IF NOT EXISTS ve_academy_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

-- Verificar que se creó correctamente
SHOW DATABASES LIKE 've_academy_db';
