#include <iostream>
using namespace std;
int divider_iterativ(int a, int b) {
    if (a < b) {
        return 0;
    }
    else if(a==b){
        return 1;
    }
    else {
        int n = 0;
        while (a >= b) {
            a -= b;
            n++;
        }
        return n;
    }
}
int divider_recursiv(int a, int b) {
    if (a < b) {
        return 0;
    }
    else if (a == b) {
        return 1;
    }
    return 1 + divider_recursiv(a - b, b);
}
int tester(int a, int b) {
    if (divider_recursiv(a, b) == divider_iterativ(a, b)) {
        return divider_iterativ(a, b);
    }
    else {
        return -1;
    }
}
int main()
{
    //int a,b;
    //cin >> a >> b;
    //cout << divider_iterativ(a, b) << endl;
    //cout << divider_recursiv(a, b) << endl;
    cout << tester(5, 5) << endl;
}