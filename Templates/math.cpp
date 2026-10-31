//统计一个数的所有因数 O(sqrt(n))
vector<int> get_divisor(int x) {
    vector<int> res;
    for (int i = 1; i <= x / i; i ++ )
        if (x % i == 0) {
            res.push_back(i);
            if (i != x / i) res.push_back(x / i);
        }
    sort(res.begin(), res.end());
    return res;
}

//判断一个数是不是质数 	O(sqrt(n))
bool is_prime (int x) {
    if (x < 2) return 0;
    for (int i = 2; i <= x / i; i ++ ) {
        if (x % i == 0) return 0;
    }
    return 1;
}

//找到一个数所有的质因数 O(sqrt(n))
void divide (int x) {
    for (int i = 2; i <= x / i; i ++ )
        if (x % i == 0) {
            int s = 0;
            while (x % i == 0) x /= i, s ++ ;
            cout << i << ' ' << s << endl;
        }
    if (x > 1) cout << x << ' ' << 1 << endl;
    cout << endl;
}

//找出1 ~ n中所有的质数 O(n)
int primes[N], len;
int vis[N];// vis[x]为1 表示x是合数

void get_primes(int n) {
    for (int i = 2; i <= n; i ++ ){
        if (!vis[i]) primes[++ len] = i;
        for (int j = 1; primes[j] * i <= n; j ++ ){
            vis[primes[j] * i] = 1;
            if (i % primes[j] == 0) break; // primes[j]一定是i的最小质因子
        }
    }
}
