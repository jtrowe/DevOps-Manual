words = ["Mary", "had", "a", "little", "lamb"]

print("normal")
print(*words)

print("separator -")
print(*words, sep="-")

print("end text")
print(*words, end="<--- This is at the end")
