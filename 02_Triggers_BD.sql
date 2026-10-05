USE `mydb`;

-- =====================================================
-- Удаляем старые триггеры, если есть (идемпотентность)
-- =====================================================
DROP TRIGGER IF EXISTS `trg_normativDocument_no_delete`;
DROP TRIGGER IF EXISTS `trg_kontrol_only_active_doc`;
DROP TRIGGER IF EXISTS `trg_oborud_overlap_insert`;
DROP TRIGGER IF EXISTS `trg_oborud_overlap_update`;
DROP TRIGGER IF EXISTS `trg_personala_overlap_insert`;
DROP TRIGGER IF EXISTS `trg_personala_overlap_update`;
DROP TRIGGER IF EXISTS `trg_brak_check`;
DROP TRIGGER IF EXISTS trg_kontrol_only_active_doc_upd;

-- =====================================================
-- 1. Запрет удаления нормативных документов
-- =====================================================
DELIMITER $$

CREATE TRIGGER `trg_normativDocument_no_delete`
BEFORE DELETE ON `normativDocument`
FOR EACH ROW
BEGIN
  SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Удаление нормативных документов запрещено. Смените статус на «Аннулирован».';
END$$

DELIMITER ;

-- =====================================================
-- 2. Ссылаться можно только на действующий документ
-- =====================================================
DELIMITER $$

CREATE TRIGGER `trg_kontrol_only_active_doc`
BEFORE INSERT ON `kontrolProducta`
FOR EACH ROW
BEGIN
  DECLARE v_status INT;
  SELECT `idStatusNormativDocument` INTO v_status
  FROM `normativDocument`
  WHERE `idNormativDocument` = NEW.`idNormativDocument`;

  IF v_status <> 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Нельзя ссылаться на недействующий нормативный документ';
  END IF;
END$$

DELIMITER ;



DELIMITER $$

CREATE TRIGGER `trg_kontrol_only_active_doc_upd`
BEFORE UPDATE ON `kontrolProducta`
FOR EACH ROW
BEGIN
  DECLARE v_status INT;
  SELECT `idStatusNormativDocument` INTO v_status
  FROM `normativDocument`
  WHERE `idNormativDocument` = NEW.`idNormativDocument`;

  IF v_status <> 1 THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Нельзя ссылаться на недействующий нормативный документ';
  END IF;
END$$

DELIMITER ;

-- =====================================================
-- 3. Оборудование не может использоваться дважды в одно время
-- =====================================================
DELIMITER $$

CREATE TRIGGER `trg_oborud_overlap_insert`
BEFORE INSERT ON `ispolzovanieOborudovaniya`
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1 FROM `ispolzovanieOborudovaniya`
    WHERE `idOborudovanie` = NEW.`idOborudovanie`
      AND NEW.`timeNachala` < `timeOkonchaniya`
      AND NEW.`timeOkonchaniya` > `timeNachala`
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Оборудование занято в этот период';
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER `trg_oborud_overlap_update`
BEFORE UPDATE ON `ispolzovanieOborudovaniya`
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1 FROM `ispolzovanieOborudovaniya`
    WHERE `idOborudovanie` = NEW.`idOborudovanie`
      AND `idIspolzovanieOborudovaniya` <> NEW.`idIspolzovanieOborudovaniya`
      AND NEW.`timeNachala` < `timeOkonchaniya`
      AND NEW.`timeOkonchaniya` > `timeNachala`
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Обновление привело к пересечению с другой записью';
  END IF;
END$$

DELIMITER ;

-- =====================================================
-- 4. Персонал не может быть занят дважды в одно время
-- =====================================================
DELIMITER $$

CREATE TRIGGER `trg_personala_overlap_insert`
BEFORE INSERT ON `rabotaPersonala`
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1 FROM `rabotaPersonala`
    WHERE `idPersonal` = NEW.`idPersonal`
      AND NEW.`timeNachala` < `timeOkonchaniya`
      AND NEW.`timeOkonchaniya` > `timeNachala`
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Сотрудник уже занят в этот период';
  END IF;
END$$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER `trg_personala_overlap_update`
BEFORE UPDATE ON `rabotaPersonala`
FOR EACH ROW
BEGIN
  IF EXISTS (
    SELECT 1 FROM `rabotaPersonala`
    WHERE `idPersonal` = NEW.`idPersonal`
      AND `idRabotaPersonala` <> NEW.`idRabotaPersonala`
      AND NEW.`timeNachala` < `timeOkonchaniya`
      AND NEW.`timeOkonchaniya` > `timeNachala`
  ) THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Обновление привело к пересечению с другой записью';
  END IF;
END$$

DELIMITER ;

-- =====================================================
-- 5. Брака не может быть больше, чем вся партия
-- =====================================================
DELIMITER $$

CREATE TRIGGER `trg_brak_check`
BEFORE INSERT ON `brak`
FOR EACH ROW
BEGIN
  DECLARE v_col INT;
  SELECT `colProducta` INTO v_col
  FROM `proizvodstvennayaPartiya`
  WHERE `idPartiya` = NEW.`idPartiya`;

  IF NEW.`colBraka` > v_col THEN
    SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Количество брака превышает размер партии';
  END IF;
END$$

DELIMITER ;