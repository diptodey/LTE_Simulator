def solution(A):

    if max(A) == 0:
        return 0

    p = min(A)

    A = [val - p for val in A]

    pivot = 0
    for i, val in enumerate(A):
        if val == 0 and A[pivot:i]:
            p += solution(A[pivot:i])
            pivot = i

    if (pivot +1) < len(A):
        p += solution(A[pivot+1: len(A)])

    return p


assert solution([8,8,8,0,7,7,2]) == 15
assert solution([8,8,8,1,7,7,2]) == 14
assert solution([8,8,0,7,0,7,2]) == 22