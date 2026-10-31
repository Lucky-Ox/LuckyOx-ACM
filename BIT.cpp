struct BIT {
    int n;
    vector<int> tr, vis;
    int tag;

    BIT(int _n = 0) { tag = 1; if (_n) init(_n); }

    void init(int _n) {
        n = _n;
        tr.assign(n + 1, 0);
        vis.assign(n + 1, 0);
        tag = 1;
    }

    int lowbit(int x) { return x & (-x); }

    // O(1) 清空：通过 tag + vis 做懒清空
    void clear() { tag ++ ; }

    inline void touch(int i) {
        if (vis[i] != tag) {
            vis[i] = tag;
            tr[i] = 0;
        }
    }

    // 单点加 k
    void add(int x, int k) {
        for (int i = x; i <= n; i += lowbit(i)) {
            touch(i);
            tr[i] += k;
        }
    }

    // 前缀和 [1..x]
    int sumPrefix(int x) {
        int res = 0;
        for (int i = x; i; i -= lowbit(i)) {
            touch(i);
            res += tr[i];
        }
        return res;
    }

    // 区间和 [l..r]
    int sumRange(int l, int r) {
        if (l > r) return 0;
        return sumPrefix(r) - sumPrefix(l - 1);
    }

    // 求第一个使得前缀和 >= k 的位置（k >= 1，且总和足够）
    int kth(int k) {
        int pos = 0;
        int bit = 1LL << __lg(n);
        for (int pw = bit; pw; pw >>= 1) {
            int nxt = pos + pw;
            if (nxt <= n) {
                touch(nxt);
                if (tr[nxt] < k) {
                    k -= tr[nxt];
                    pos = nxt;
                }
            }
        }
        return pos + 1;
    }
};
