-- 1. Справочник моделей транспортных средств
CREATE TABLE VehicleModels (
    ID_Model SERIAL PRIMARY KEY,
    ModelName VARCHAR(100) NOT NULL,
    ServiceLife INT NOT NULL,            -- Срок службы в годах
    MaxMileage INT NOT NULL              -- Максимальный пробег до списания (км)
);

-- 2. Реестр транспортных средств (парк)
create table Vehicles (
    ID_Vehicle SERIAL primary key,
    Model_ID INT not null,
    SerialNumber VARCHAR(50) unique not null,
-- Серийный номер
RegNumber VARCHAR(20) unique not null,
-- Госномер
YearOfManufacture INT not null,
    CurrentMileage INT default 0,
-- Текущий пробег для контроля списания
    foreign key (Model_ID) references VehicleModels(ID_Model)
);

-- 3. Список посадочных мест для каждого транспортного средства
CREATE TABLE Seats (
    ID_Seat SERIAL PRIMARY KEY,
    Vehicle_ID INT NOT NULL,
    SeatNumber VARCHAR(10) NOT NULL,
    UNIQUE (Vehicle_ID, SeatNumber), -- Ограничение: номера мест уникальны внутри одного ТС
    FOREIGN KEY (Vehicle_ID) REFERENCES Vehicles(ID_Vehicle) ON DELETE CASCADE
);

-- 4. Маршрутная сеть
CREATE TABLE Routes (
    ID_Route SERIAL PRIMARY KEY,
    StartPoint VARCHAR(100) NOT NULL,
    EndPoint VARCHAR(100) NOT NULL,
    Distance DECIMAL(10, 2) NOT NULL,    -- Протяженность в км
    Duration INTERVAL NOT NULL           -- Время в пути (формат 'HH:MI')
);

-- 5. Расписание рейсов
CREATE TABLE Trips (
    ID_Trip SERIAL PRIMARY KEY,
    Route_ID INT NOT NULL,
    Vehicle_ID INT NOT NULL,
    DepartureDateTime TIMESTAMP NOT NULL,
    DriverFullName VARCHAR(150) NOT NULL,
    FOREIGN KEY (Route_ID) REFERENCES Routes(ID_Route),
    FOREIGN KEY (Vehicle_ID) REFERENCES Vehicles(ID_Vehicle)
);

-- 6. Продажа билетов
CREATE TABLE Tickets (
    ID_Ticket SERIAL PRIMARY KEY,
    Trip_ID INT NOT NULL,
    Seat_ID INT NOT NULL,
    PassengerFullName VARCHAR(150) NOT NULL,
    -- Уникальный индекс гарантирует, что на один рейс нельзя продать одно место дважды
    UNIQUE (Trip_ID, Seat_ID), 
    FOREIGN KEY (Trip_ID) REFERENCES Trips(ID_Trip),
    FOREIGN KEY (Seat_ID) REFERENCES Seats(ID_Seat)
);
