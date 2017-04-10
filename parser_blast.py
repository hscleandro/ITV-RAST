# Author: Leandro Correa
# Date: 16.09.2016

def parser_blast(file):

    vet_query = []
    vet_sequence = []
    vet_score = []
    vet_evalue = []
    found = True

    for line in open(file, 'r'):
        if found == True:

            not_found = line[0:5]
            if not_found == '*****':
                vet_query.pop()

            query = line[0:6]
            if query == 'Query=':
                temp1 = line[8:]
                temp1 = temp1[:-1]
                vet_query.append(temp1)

            sproduc = line[0:9]
            if sproduc == 'Sequences':
                found = False
                i = 1
        else:
            if i == 2:
                temp2 = line
                temp2 = temp2[:-1]
                seqt = temp2.split('  ')
                seq = seqt[0] + ' ' + seqt[1]
                vet_sequence.append(seq)
                temp3 = temp2.split('  ')
                for x in range(2, len(temp3)):
                    if temp3[x] != '':
                        vet_score.append(temp3[x])
                        vet_evalue.append(temp3[x+2])
                        break
                found = True
            i += 1

    # print '------ parser successfully executed ------'

    matrix = []
    matrix.append(['Query', 'Sequence', 'Score', 'eValue'])
    for i in range(len(vet_query)):
        matrix.append([vet_query[i], vet_sequence[i], vet_score[i], vet_evalue[i]])

    return matrix