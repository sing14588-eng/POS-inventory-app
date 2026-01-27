const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = mongoose.Schema({
    name: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
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
    onboardingCompleted: { type: Boolean, default: false },
}, {
    timestamps: true,
});

userSchema.methods.matchPassword = async function (enteredPassword) {
    return await bcrypt.compare(enteredPassword, this.password);
};

// Encrypt password using bcrypt
userSchema.pre('save', async function (next) {
    if (!this.isModified('password')) {
        next();
    }
    const salt = await bcrypt.genSalt(10);
    this.password = await bcrypt.hash(this.password, salt);
});

const User = mongoose.model('User', userSchema);

module.exports = User;
