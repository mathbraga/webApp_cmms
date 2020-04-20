create domain precision_value as numeric
    check(
        scale(value) < 3
    );

create domain location_value as numeric;