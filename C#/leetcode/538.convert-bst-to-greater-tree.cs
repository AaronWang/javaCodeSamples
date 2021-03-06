/*
 * @lc app=leetcode id=538 lang=csharp
 *
 * [538] Convert BST to Greater Tree
 */

namespace ConvetBST
{
    // Definition for a binary tree node.
    public class TreeNode
    {
        public int val;
        public TreeNode left;
        public TreeNode right;
        public TreeNode(int val = 0, TreeNode left = null, TreeNode right = null)
        {
            this.val = val;
            this.left = left;
            this.right = right;
        }
    }

    // @lc code=start
    public class Solution
    {
        public int sum = 0;
        public TreeNode ConvertBST(TreeNode root)
        {
            if (root == null) return root;
            RecursionSolution(root);
            return root;
        }
        // [2,0,3,-4,1]
        // [4,1,6,0,2,5,7,null,null,null,3,null,null,null,8]
        public void RecursionSolution(TreeNode root)
        {
            if (root != null)
            {
                RecursionSolution(root.right);
                root.val += sum;
                sum = root.val;
                RecursionSolution(root.left);
            }
        }
    }
    // @lc code=end

}