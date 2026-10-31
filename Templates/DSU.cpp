struct DSU {
    int n;
    vector<int> p, sz;

    DSU() : n(0) {}
    DSU(int n_) { init(n_); }

    void init(int n_) {
        n = n_;
        p.resize(n + 1);
        sz.assign(n + 1, 1);
        iota(p.begin(), p.end(), 0);
    }

    int find(int x) {
        if (x != p[x]) p[x] = find(p[x]);
        return p[x];
    }

    bool same(int a, int b) {
        return find(a) == find(b);
    }

    bool merge(int a, int b) {
        a = find(a), b = find(b);
        if (a == b) return false;
        if (sz[a] < sz[b]) swap(a, b);
        p[b] = a;
        sz[a] += sz[b];
        return true;
    }

    int size(int x) {
        return sz[find(x)];
    }
    
};
