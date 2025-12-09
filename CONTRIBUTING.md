# Contributing to Kurtosis Kubernetes Testnet

Thank you for your interest in contributing to this project! This document provides guidelines and information for contributors.

## Development Setup

### Prerequisites

1. Install [Kurtosis](https://docs.kurtosis.com/install/):
   ```bash
   # macOS
   brew install kurtosis-tech/tap/kurtosis-cli
   
   # Linux
   curl -fsSL https://get.kurtosis.com | bash
   
   # Windows
   # See https://docs.kurtosis.com/install/
   ```

2. Ensure Docker or Podman is running

### Local Testing

Test your changes locally:

```bash
# Run with default configuration
kurtosis run . 

# Run with custom configuration
kurtosis run . '{"num_nodes": 5, "enable_monitoring": true}'

# Clean up after testing
kurtosis clean -a
```

## Making Changes

### Code Structure

- `kurtosis.yml` - Package manifest
- `main.star` - Main Starlark script (entry point)
- `README.md` - User documentation
- `config.example.json` - Example configuration

### Starlark Style Guide

- Use 4 spaces for indentation
- Use descriptive variable names
- Add comments for complex logic
- Keep functions focused and single-purpose

### Testing Your Changes

Before submitting a PR:

1. Test with default configuration
2. Test with various node counts (1, 3, 10)
3. Test with monitoring enabled/disabled
4. Verify all services start correctly
5. Check logs for errors

```bash
# Example test commands
kurtosis run . '{"num_nodes": 1}'
kurtosis run . '{"num_nodes": 10}'
kurtosis run . '{"enable_monitoring": true}'
```

## Submitting Changes

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit your changes (`git commit -m 'Add amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Commit Messages

- Use clear, descriptive commit messages
- Start with a verb in present tense (Add, Fix, Update, etc.)
- Keep the first line under 50 characters
- Add detailed description if needed

Examples:
```
Add support for custom node images
Fix port conflict in monitoring setup
Update documentation for configuration options
```

## Ideas for Contributions

Here are some ways you can contribute:

### Features
- Add support for different container images
- Implement custom networking configurations
- Add health check endpoints
- Support for persistent storage
- Integration with CI/CD pipelines

### Documentation
- Add more usage examples
- Create troubleshooting guides
- Add architecture diagrams
- Translate documentation

### Testing
- Add test scenarios
- Create integration tests
- Performance testing

## Questions?

If you have questions:
- Open an issue for discussion
- Check existing issues and PRs
- Review the [Kurtosis documentation](https://docs.kurtosis.com)

## Code of Conduct

Be respectful and constructive in all interactions. We're all here to learn and improve this project together.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
