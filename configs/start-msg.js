const chalk = require('chalk');
console.log(chalk`

 🎉 {green Services appear to be starting!} 
 You can monitor from the status page: {underline.bold.blue https://app.localhost}
{dim 
Troubleshooting Tips:
    If the connection is refused, check the nginx logs. 
    If the domain cannot be resolved, check that your system properly handles the .localhost tld.
    If the certificate is not trusted, you will have to manually trust the certificate.
}
`);