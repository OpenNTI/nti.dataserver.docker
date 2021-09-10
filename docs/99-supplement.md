# nti.dataserver [Docker Edition] - Supplemental

## Why tcp8083

Reasons. 😜

Just kidding!

The original buildout listened on tcp8083 for web/mobile apps. To be compatible with the non-containerized environments, and to prevent project churn, we will leave the port that we expect to be the same. This also keeps traditional ports free for side projects to run side-by-side.

---
