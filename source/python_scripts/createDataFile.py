f = open('data/rawDataFromRotoGuru/fd_2015.txt')
f.readline()

data = []
for line in f:
    sp = line.strip().split(';')

    fantasyPoints = float(sp[5])

    salaryStr = sp[6]
    if salaryStr == 'N/A':
        continue
    salary = int(sp[6][1:].replace(',', ''))

    data.append((fantasyPoints, salary))
f.close()

f = open('data/data.csv', 'w')
f.write('FantasyPoints,Salary\n')
for d in data:
    f.write(','.join(map(str, d)) + '\n')
f.close()
