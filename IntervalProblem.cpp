//区间合并
//https://www.acwing.com/problem/content/805/
int n;
struct node {
    int l, r;
    bool operator < (const node &that) const {
        return l < that.l;//先以左端点升序排序 右端点怎么样无所谓
    }
}a[N];
void solve() {
    cin >> n;
    for(int i = 1; i <= n; i ++ ) cin >> a[i].l >> a[i].r;
    sort(a + 1, a + n + 1);

    int ans = 0, R = -INF;//R表示上一个区间的右端点
    for(int i = 1; i <= n; i ++ ) {
        if(a[i].l > R) {//如果当前区间的左端点在上一个区间的右端点右方的话 意味着不能合并 我们需要新开一个区间
            ans ++ ;
            R = a[i].r;
        }
        else R = max(R, a[i].r);//可以合并的话 更新区间的右端点
    }
    cout << ans << endl;
}

//区间合并的变种问题:对于区间x来说 有多少个区间满足l <= x.l && r >= x.l;
//https://codeforces.com/gym/105385/problem/F
int n;
struct node{
    int l, r;
    bool operator < (const node &that) const {
        return l < that.l;
    }
}a[N];
void solve() {
    cin >> n;
    for(int i = 1; i <= n; i ++ ) cin >> a[i].l >> a[i].r;
    sort(a + 1, a + n + 1);

    priority_queue<int, vector<int>, greater<int> >q;
    for(int i = 1; i <= n; i ++ ) {
        while(!q.empty() && q.top() < a[i].l) q.pop();//如果之间区间的右端点比区间i的左端点靠左 那么他们就不会相交
        //此时q.size()就是要求的
        q.push(a[i].r);
    }
}