const brandColor = '#000000'; // Pure black
const accentColor = '#333333'; // Dark gray
const textColor = '#1A1A1A'; // Near black
const lightBg = '#F5F5F5'; // Off-white/light gray

const baseTemplate = (content, logoUrl) => `
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
</head>
<body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; line-height: 1.6; color: ${textColor}; margin: 0; padding: 0; background-color: #ffffff;">
    <div style="max-width: 600px; margin: 40px auto; background: #ffffff; border: 1px solid #E0E0E0; border-radius: 4px; overflow: hidden;">
        <div style="background-color: #ffffff; padding: 24px 32px; border-bottom: 2px solid #000000;">
            <table style="width: 100%; border-collapse: collapse;">
                <tr>
                    <td style="width: 80px; vertical-align: middle;">
                        <img src="${logoUrl}" alt="FlowPos" style="width: 80px; height: auto; display: block; border: 0;">
                    </td>
                    <td style="padding-left: 20px; vertical-align: middle;">
                        <div style="font-size: 22px; font-weight: 800; color: #000000; letter-spacing: 2px; text-transform: uppercase; line-height: 1;">FlowPos</div>
                    </td>
                </tr>
            </table>
        </div>
        <div style="padding: 48px; background-color: #ffffff;">
            ${content}
        </div>
        <div style="background-color: ${lightBg}; padding: 24px; text-align: center; font-size: 11px; color: #666; text-transform: uppercase; letter-spacing: 1px;">
            <p style="margin: 0; font-weight: 700;">&copy; ${new Date().getFullYear()} FlowPos Management Suite</p>
            <p style="margin: 8px 0 0 0; opacity: 0.7;">Secure System Access Notification</p>
        </div>
    </div>
</body>
</html>
`;

const welcomeTemplate = (name, email, logoUrl) => baseTemplate(`
    <h1 style="margin-top: 0; font-size: 24px; font-weight: 800; border-bottom: 2px solid #000; padding-bottom: 12px; display: inline-block;">VERIFIED ACCESS</h1>
    <p style="margin-top: 24px; font-size: 16px;">Welcome to the Platform Hub, <strong>${name}</strong>.</p>
    <p>Your executive account has been successfully linked to the FlowPos ecosystem. You have been granted full permissions for:</p>
    <table style="width: 100%; margin: 24px 0; border-collapse: collapse;">
        <tr><td style="padding: 8px 0; border-bottom: 1px solid #EEE;">&bull; Tenant Shop Management</td></tr>
        <tr><td style="padding: 8px 0; border-bottom: 1px solid #EEE;">&bull; Executive Analytics & Reporting</td></tr>
        <tr><td style="padding: 8px 0; border-bottom: 1px solid #EEE;">&bull; Security Configuration</td></tr>
        <tr><td style="padding: 8px 0;">&bull; Subscription & Plan Management</td></tr>
    </table>
    <p style="font-size: 13px; color: #666;">Identity: <span style="color: #000; font-weight: 600;">${email}</span></p>
    <div style="margin-top: 40px;">
        <a href="#" style="display: inline-block; padding: 16px 32px; background-color: #000000; color: #ffffff; text-decoration: none; border-radius: 0; font-size: 14px; font-weight: 600; text-transform: uppercase; letter-spacing: 1px;">Enter Workspace</a>
    </div>
`, logoUrl);

const genericAlertTemplate = (title, message) => baseTemplate(`
    <h2 style="color: ${brandColor};">${title}</h2>
    <p>${message}</p>
`);

const credentialsTemplate = (shopName, shopId, credentials, logoUrl) => baseTemplate(`
    <h1 style="margin-top: 0; font-size: 24px; font-weight: 800; border-bottom: 2px solid #000; padding-bottom: 12px; display: inline-block;">SHOP PROVISIONED</h1>
    <p style="margin-top: 24px; font-size: 16px;">Welcome, <strong>${shopName}</strong>!</p>
    <p>Your shop has been successfully set up on FlowPOS. Below are your initial administrative credentials.</p>
    
    <div style="background-color: #F9F9F9; padding: 20px; border-radius: 8px; margin: 24px 0; border: 1px solid #EEE;">
        <p style="margin: 0; font-size: 12px; text-transform: uppercase; color: #666; font-weight: 700;">Admin Username</p>
        <p style="margin: 4px 0 16px 0; font-size: 18px; font-weight: 800; color: #000; font-family: monospace;">${credentials.admin.username}</p>
        
        <p style="margin: 0; font-size: 12px; text-transform: uppercase; color: #666; font-weight: 700;">Temporary Password</p>
        <p style="margin: 4px 0 0 0; font-size: 18px; font-weight: 800; color: #000; font-family: monospace;">${credentials.admin.password}</p>
    </div>

    <p style="font-size: 13px; color: #666; line-height: 1.5;">
        <strong style="color: #E63946;">IMPORTANT:</strong> For security reasons, you will be required to change your password upon your first login.
    </p>

    <div style="margin-top: 40px;">
        <a href="https://flowpos.app/login" style="display: inline-block; padding: 16px 32px; background-color: #000000; color: #ffffff; text-decoration: none; border-radius: 0; font-size: 14px; font-weight: 600; text-transform: uppercase; letter-spacing: 1px;">Login to Shop</a>
    </div>
`, logoUrl);

module.exports = { welcomeTemplate, genericAlertTemplate, credentialsTemplate };
