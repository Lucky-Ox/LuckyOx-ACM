struct Tire {
    int son[N][70], cnt[N], idx;

    int getnum(char x){ //可以将数字 大小写字母转化成数字
        if(x >= 'A' && x <= 'Z') return x - 'A';
        else if(x >= 'a' && x <= 'z') return x - 'a' + 26;
        else return x - '0' + 52;
    }

    void clear() {
        for(int i = 0; i <= idx; i ++ ) {
            cnt[i] = 0;
            for(int j = 0; j <70; j ++ ) son[i][j] = 0;
        }
        idx = 0;
    }

    void insert(string s){
        int p = 0;
        int len = s.size();
        for (int i = 0; i < len; i ++ ){
            int j = getnum(s[i]);
            if (!son[p][j]) son[p][j] = ++ idx;
            p = son[p][j];
            // cnt[p] ++ 可以统计 s作为字符的前缀出现过几次
        }
        cnt[p] ++ ; // 写在这里 可以统计s出现过几次
    }

    int query(string s){
        int p = 0;
        int len = s.size();
        for (int i = 0; i < len; i ++ ){
            int j = getnum(s[i]);
            if (!son[p][j]) return 0;
            p = son[p][j];
        }
        return cnt[p];
    }
};
