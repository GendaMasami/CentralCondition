const express = require('express');
const router = express.Router();
const { authenticateUser, generateToken, authMiddleware, checkPermission } = require('./middleware');

// ログインエンドポイント
router.post('/login', async (req, res) => {
    const { username, password } = req.body;

    if (!username || !password) {
        return res.status(400).json({ error: 'ユーザー名とパスワードが必要です' });
    }

    const user = await authenticateUser(username, password);
    if (!user) {
        return res.status(401).json({ error: '認証に失敗しました' });
    }

    const token = generateToken(user);
    res.json({
        token,
        user: {
            username: user.username,
            roles: user.roles,
            permissions: user.permissions
        }
    });
});

// ユーザー情報取得エンドポイント
router.get('/me', authMiddleware, (req, res) => {
    res.json({
        username: req.user.username,
        roles: req.user.roles,
        permissions: req.user.permissions
    });
});

// 権限チェックテストエンドポイント
router.get('/test-permission', authMiddleware, checkPermission('read'), (req, res) => {
    res.json({ message: '権限チェックに成功しました' });
});

module.exports = router; 