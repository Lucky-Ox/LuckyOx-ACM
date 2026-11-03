class Solution {
public:
    int lengthOfLongestSubstring(string s) {
        int n = s.size();

        int ans = 0;
        int cnt[256];
        memset(cnt, 0, sizeof cnt);
        for(int l = 0, r = -1; l < n; cnt[s[l ++ ]] -- ) {
            while(r + 1 < n && cnt[s[r + 1]] == 0) {
                cnt[s[r + 1]] ++ ;
                r ++ ;
            }
            ans = max(ans, r - l + 1);
        }
        return ans;
    }
};