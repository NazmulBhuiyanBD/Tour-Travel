WITH flight_data(
    airline,
    from_city,
    to_city,
    economy,
    premium,
    business,
    first_class,
    departure_time,
    arrival_time
) AS (
    VALUES
        ('SkyJet Airlines', 'Dhaka', 'Dubai', 120, 40, 20, 10, TIMESTAMP '2026-05-25 09:00:00', TIMESTAMP '2026-05-25 13:00:00'),
        ('Air Nova', 'New York', 'London', 150, 50, 25, 15, TIMESTAMP '2026-05-28 20:30:00', TIMESTAMP '2026-05-29 07:00:00'),
        ('BlueWing Air', 'London', 'Paris', 80, 20, 10, 5, TIMESTAMP '2026-05-30 10:00:00', TIMESTAMP '2026-05-30 12:00:00'),
        ('Golden Air', 'Dubai', 'Tokyo', 180, 60, 30, 20, TIMESTAMP '2026-06-02 18:00:00', TIMESTAMP '2026-06-03 06:00:00'),
        ('FlyAsia Express', 'Singapore', 'Bangkok', 100, 25, 10, 0, TIMESTAMP '2026-06-05 14:00:00', TIMESTAMP '2026-06-05 16:00:00'),
        ('Oceanic Airlines', 'Sydney', 'Melbourne', 90, 20, 12, 6, TIMESTAMP '2026-06-08 11:00:00', TIMESTAMP '2026-06-08 12:30:00'),
        ('Horizon Airlines', 'Delhi', 'Dhaka', 110, 35, 15, 5, TIMESTAMP '2026-06-12 07:00:00', TIMESTAMP '2026-06-12 10:00:00'),
        ('StarFly Airways', 'Toronto', 'Vancouver', 140, 45, 20, 10, TIMESTAMP '2026-06-15 13:00:00', TIMESTAMP '2026-06-15 17:00:00'),
        ('Emirates Sky', 'Dubai', 'Singapore', 170, 55, 28, 12, TIMESTAMP '2026-06-18 15:00:00', TIMESTAMP '2026-06-18 23:00:00'),
        ('Pacific Air', 'Tokyo', 'Seoul', 95, 30, 15, 5, TIMESTAMP '2026-06-21 09:30:00', TIMESTAMP '2026-06-21 12:30:00'),
        ('EuroFly', 'Paris', 'Rome', 85, 25, 10, 5, TIMESTAMP '2026-06-23 16:00:00', TIMESTAMP '2026-06-23 18:00:00'),
        ('Royal Wings', 'Dhaka', 'Kuala Lumpur', 130, 40, 18, 8, TIMESTAMP '2026-06-25 23:00:00', TIMESTAMP '2026-06-26 05:00:00')
),
inserted AS (
    INSERT INTO "Flights" (
        "Airline",
        "From",
        "To",
        "DepartureTime",
        "ArrivalTime",
        "Price",
        "AvailableSeats",
        "IsPopular"
    )
    SELECT
        airline,
        from_city,
        to_city,
        departure_time,
        arrival_time,
        500,
        economy + premium + business + first_class,
        airline IN ('SkyJet Airlines', 'Emirates Sky', 'Royal Wings')
    FROM flight_data fd
    WHERE NOT EXISTS (
        SELECT 1
        FROM "Flights" f
        WHERE f."Airline" = fd.airline
            AND f."From" = fd.from_city
            AND f."To" = fd.to_city
            AND f."DepartureTime" = fd.departure_time
    )
    RETURNING "Id", "Airline", "From", "To", "DepartureTime"
),
class_source AS (
    SELECT
        i."Id" AS flight_id,
        v.class_name,
        v.seats,
        v.price
    FROM inserted i
    JOIN flight_data fd
        ON fd.airline = i."Airline"
        AND fd.from_city = i."From"
        AND fd.to_city = i."To"
        AND fd.departure_time = i."DepartureTime"
    CROSS JOIN LATERAL (
        VALUES
            ('Economy', fd.economy, 500),
            ('Premium Economy', fd.premium, 900),
            ('Business', fd.business, 1500),
            ('First Class', fd.first_class, 2500)
    ) AS v(class_name, seats, price)
)
INSERT INTO "FlightSeatClasses" (
    "FlightId",
    "ClassName",
    "AvailableSeats",
    "Price"
)
SELECT
    flight_id,
    class_name,
    seats,
    price
FROM class_source;
