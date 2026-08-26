def get_users() -> dict[int, str]:
    users: dict[int, str] = {1: "Alice", 2: "Bob", 3: "Carol"}
    return users


def display_users(users: dict[int, str]) -> None:
    for k, v in users.items():
        print(k, v, sep=": ")


def main() -> None:
    print("A users var with correct key/value types")
    users: dict[int, str] = get_users()
    display_users(users)

    print("A users var with incorrect key/value types, but it still works")
    users2 = {
        "d": "Dave",
        "e": 13,
        4: 3,
    }
    display_users(users2)


if "__main__" == __name__:
    main()
