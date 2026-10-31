#include<bits/stdc++.h> // By Lucky_Ox
#define int long long
#define endl "\n"
using namespace std;
using i128 = __int128;
using u64 = unsigned long long;
using pii = pair<int, int>;
int P(int x, int p){ return (x % p + p) % p; }
int gcd(int a, int b) { return b == 0 ? a : gcd(b, a % b); }
int lcm(int x, int y) { return x / gcd(x, y) * y; }
int len_10(int x) { int len = 0; while(x) { x /= 10; len ++ ; } return len; }
int q_pow(int a, int k, int p) { int res = 1; while (k) { if (k & 1) res = res * a % p; k >>= 1; a = a * a % p; } return res; }
int to_int(string s) { int val = 0; for(int i = 0; i < (int)s.size(); i ++ ){ val *= 10; val += s[i] - '0'; } if(val == 0) cout << "s is null" << endl; return val; }
i128 read() { i128 x = 0; char c = getchar(); while (c < '0' || c > '9') c = getchar(); while (c >= '0' && c <= '9') { x = x * 10 + c - '0'; c = getchar(); } return x; }
void print(i128 x) { if(x > 9) print(x / 10); putchar((int)(x % 10) + '0'); }
constexpr int mod = LLONG_MAX, INF = LLONG_MAX;

int ask(int i, int j) {
    cout << "? " << i << " " << j << "\n";
    cout.flush();

    int res;
    cin >> res;
    if (res == -1) exit(0);
    return res;
}

void answer(int x) {
    cout << "! " << x << "\n";
    cout.flush();
}

void solve() {
    int n;
    cin >> n;

    for (int i = 1; i <= 2 * n - 4; i += 2) {
        int res = ask(i, i + 1);
        if (res == 1) {
            answer(i);
            return;
        }
    }

    // 剩下 4 个位置
    int x = 2 * n - 3, y = 2 * n - 2, z = 2 * n - 1, w = 2 * n;

    if (ask(x, y) == 1) {
        answer(x);
        return;
    }
    if (ask(x, z) == 1) {
        answer(x);
        return;
    }
    if (ask(y, z) == 1) {
        answer(y);
        return;
    }
    answer(w);
}

signed main() {
    ios::sync_with_stdio(false);cin.tie(nullptr);
    int T = 1;
    cin >> T;
    while (T -- ) solve();
    return 0;
}
