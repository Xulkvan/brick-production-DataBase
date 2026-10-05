@echo off
chcp 65001 >nul
echo ========================================
echo  Развёртывание БД "Производство кирпича"
echo ========================================
echo.

echo [1/4] Создание схемы...
mysql -u root -p < 01_schema\01_Sozdanie_BD.sql
if errorlevel 1 goto error

echo [2/4] Установка триггеров...
mysql -u root -p < 02_triggers\02_Triggers_BD.sql
if errorlevel 1 goto error

echo [3/4] Загрузка данных...
mysql -u root -p < 03_data\03_Zapolnenie_BD.sql
if errorlevel 1 goto error

echo [4/4] Создание представлений...
mysql -u root -p < 04_views\04_Sozdanie_VIEWS.sql
if errorlevel 1 goto error

echo.
echo ========================================
echo  Готово! База данных развёрнута.
echo ========================================
pause
exit /b 0

:error
echo.
echo ОШИБКА при выполнении скрипта. Проверьте подключение к MySQL.
pause
exit /b 1