students = ["Alice", "Bob", "Charlie", "David"]
grades = [85, 90, 78, 92]
colors = ["blue", "red", "yellow"]
lunches = [
    {"sandwich": "turkey", "drink": "tea"},
    {"sandwich": "ham", "drink": "coffee"},
    {"sandwich": "beef", "drink": "beer"},
    {"sandwich": "bologna", "drink": "cola"},
]

# Use zip to create pairs of student and grade
for student, grade, color, lunch in zip(students, grades, colors, lunches):
    print(f"{student}: {grade} {color} {lunch}")

print(list(zip(students, grades)))
