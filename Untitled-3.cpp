#include<bits/stdc++.h> // By LuckyOx
using namespace std;
using i64 = long long;
using i128 = __int128;
using u64 = unsigned long long;
using pii = pair<int, int>;
int P(int x, int p){ return (x % p + p) % p; }
int  gcd(int a, int b) { return b == 0 ? a : gcd(b, a % b); }
int lcm(int x, int y) { return x / gcd(x, y) * y; }
int len_10(int x) { int len = 0; while(x) { x /= 10; len ++ ; } return len; }
int q_pow(int a, int k, int p) { int res = 1; while (k) { if (k & 1) res = res * a % p; k >>= 1; a = a * a % p; } return res; }
int to_int(string s) { int val = 0; for(int i = 0; i < (int)s.size(); i ++ ){ val *= 10; val += s[i] - '0'; } if(val == 0) cout << "s is null" << endl; return val; }
i128 read() { i128 x = 0; char c = getchar(); while (c < '0' || c > '9') c = getchar(); while (c >= '0' && c <= '9') { x = x * 10 + c - '0'; c = getchar(); } return x; }
void print(i128 x) { if(x > 9) print(x / 10); putchar(x % 10 + '0'); }
constexpr int mod = LLONG_MAX, INF = LLONG_MAX;
//用__lg()来求一个数二进制下的位数 返回的len 表示这个数是[0, 1, ...., len] 比如10 __lg(10) = 3, 1010 [3, 2, 1, 0]
//__builtin_popcountll(int x) 求二进制下x中1的数量 __buitlin_ctzll(int x) 求二进制下末尾0的个数
//将x转换成[1, n]中对应的数 (x - 1) % n + 1

void solve() {

}

signed main() {
    ios::sync_with_stdio(false);cin.tie(nullptr);
    int T = 1;
    //cin >> T;
    while (T -- ) solve();
    return 0;
}
