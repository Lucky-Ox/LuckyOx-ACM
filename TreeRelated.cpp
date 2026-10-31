//求树中所有节点的深度, 到叶子结点的最远距离, 所有子树的节点个数
//https://www.luogu.com.cn/problem/P5908
void dfs(int u, int fa) {
    d[u] = d[fa] + 1; //定义d为该节点的深度 根节点的d = 1
    for(int v : e[u]) {
        if(v == fa) continue;

        dfs(v, u);
        vd[u] = max(vd[u], vd[v] + 1);//定义vd是到其叶子结点的距离 叶子节点的vd=0
        sz[u] += sz[v]; //sz[i] 表示编号为i的子树(包含其本身)的节点数量
    }
}

//从树上某一点出发遍历所有节点的最短路径长度
//节点数n, ans = 2 * (n - 1) – R, R为该点到所有点的最长路径

