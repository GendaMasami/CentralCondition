const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const fs = require('fs');
const path = require('path');

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const USERS_FILE = path.join(__dirname, '../rbac/users.json');

// ユーザー情報の読み込み
const loadUsers = () => {
    const data = fs.readFileSync(USERS_FILE, 'utf8');
    return JSON.parse(data);
};

// ユーザー認証
const authenticateUser = async (username, password) => {
    const { users } = loadUsers();
    const user = users.find(u => u.username === username);
    
    if (!user) {
        return null;
    }

    const isValid = await bcrypt.compare(password, user.password_hash);
    if (!isValid) {
        return null;
    }

    return {
        username: user.username,
        roles: user.roles,
        permissions: user.permissions
    };
};

// JWTトークンの生成
const generateToken = (user) => {
    return jwt.sign(
        {
            username: user.username,
            roles: user.roles,
            permissions: user.permissions
        },
        JWT_SECRET,
        { expiresIn: '24h' }
    );
};

// 認証ミドルウェア
const authMiddleware = (req, res, next) => {
    const token = req.headers.authorization?.split(' ')[1];
    
    if (!token) {
        return res.status(401).json({ error: '認証が必要です' });
    }

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        req.user = decoded;
        next();
    } catch (error) {
        return res.status(401).json({ error: '無効なトークンです' });
    }
};

// 権限チェックミドルウェア
const checkPermission = (requiredPermission) => {
    return (req, res, next) => {
        if (!req.user) {
            return res.status(401).json({ error: '認証が必要です' });
        }

        if (req.user.permissions.includes('*') || 
            req.user.permissions.includes(requiredPermission)) {
            next();
        } else {
            res.status(403).json({ error: '権限がありません' });
        }
    };
};

module.exports = {
    authenticateUser,
    generateToken,
    authMiddleware,
    checkPermission
}; 