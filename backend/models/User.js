const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = mongoose.Schema({
    name: { type: String, required: true },
    username: { type: String, unique: true, sparse: true }, // For code-based login
    email: { type: String, unique: true, sparse: true }, // sparse allows multiple nulls
    password: { type: String, required: true },
    roles: [{
        type: String,
        required: true,
        enum: ['sales', 'picker', 'accountant', 'warehouse', 'admin', 'super_admin']
    }],
    company: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Company',
        required: false // Optional for super_admins or during migration
    },
    branch: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Branch'
    },
    isActive: { type: Boolean, default: true },
    passwordChanged: { type: Boolean, default: true },
    onboardingCompleted: { type: Boolean, default: false },
    welcomeEmailSent: { type: Boolean, default: false },
}, {
    timestamps: true,
});

userSchema.methods.matchPassword = async function (enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.password);
};

// Encrypt password using bcrypt
userSchema.pre('save', async function () {
    if (!this.isModified('password')) {
        return;
    }
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
});

const User = mongoose.model('User', userSchema);

module.exports = User;
