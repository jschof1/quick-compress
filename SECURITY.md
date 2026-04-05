# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.0.x   | :white_check_mark: |

## Reporting a Vulnerability

If you discover a security vulnerability in Quick Compress, please report it by opening an issue on GitHub.

We take all security issues seriously and will respond as quickly as possible.

## Security Considerations

Quick Compress:

- Executes shell commands (ImageMagick)
- Processes user-provided file paths
- Creates temporary files

Please ensure:

- Only run on files you trust
- Don't run with elevated privileges unnecessarily
- Temporary files are cleaned up automatically

## Safe Usage

```bash
# Good - process your own files
compress ~/my-photos/

# Avoid - processing untrusted files from unknown sources
compress /tmp/suspicious-files/
```
