#!/usr/bin/env python3
import os
import sys
import stat
import argparse
from pathlib import Path

def set_permissions(path, mode, recursive=False):
    """Set permissions for a file or directory."""
    try:
        if recursive and os.path.isdir(path):
            for root, dirs, files in os.walk(path):
                for d in dirs:
                    os.chmod(os.path.join(root, d), mode)
                for f in files:
                    os.chmod(os.path.join(root, f), mode)
        os.chmod(path, mode)
        print(f"Set permissions {oct(mode)} on {path}")
    except Exception as e:
        print(f"Error setting permissions on {path}: {str(e)}")

def main():
    parser = argparse.ArgumentParser(description='Set Laravel application permissions')
    parser.add_argument('path', help='Path to Laravel application root directory')
    parser.add_argument('--user', default='www-data', help='Web server user (default: www-data)')
    parser.add_argument('--group', default='www-data', help='Web server group (default: www-data)')
    args = parser.parse_args()

    # Convert to absolute path
    base_path = Path(args.path).resolve()
    
    if not base_path.exists():
        print(f"Error: Path {base_path} does not exist")
        sys.exit(1)

    # Directories that need 755 permissions
    dirs_755 = [
        base_path,
        base_path / 'app',
        base_path / 'bootstrap',
        base_path / 'config',
        base_path / 'database',
        base_path / 'public',
        base_path / 'resources',
        base_path / 'routes',
        base_path / 'tests',
        base_path / 'vendor',
    ]

    # Directories that need 775 permissions
    dirs_775 = [
        base_path / 'storage',
        base_path / 'bootstrap/cache',
    ]

    # Files that need 644 permissions
    files_644 = [
        base_path / '.env',
        base_path / '.env.example',
        base_path / 'composer.json',
        base_path / 'composer.lock',
        base_path / 'package.json',
        base_path / 'package-lock.json',
        base_path / 'phpunit.xml',
        base_path / 'server.php',
        base_path / 'webpack.mix.js',
    ]

    try:
        # Set ownership
        print(f"\nSetting ownership to {args.user}:{args.group}")
        for path in dirs_755 + dirs_775:
            if path.exists():
                os.system(f"chown -R {args.user}:{args.group} {path}")
                print(f"Set ownership on {path}")

        # Set directory permissions
        print("\nSetting directory permissions")
        for path in dirs_755:
            if path.exists():
                set_permissions(path, 0o755, recursive=True)

        for path in dirs_775:
            if path.exists():
                set_permissions(path, 0o775, recursive=True)

        # Set file permissions
        print("\nSetting file permissions")
        for path in files_644:
            if path.exists():
                set_permissions(path, 0o644)

        # Special case for storage directory
        storage_path = base_path / 'storage'
        if storage_path.exists():
            # Ensure storage directory is writable
            set_permissions(storage_path, 0o775, recursive=True)
            
            # Create necessary storage subdirectories if they don't exist
            storage_dirs = ['app', 'framework', 'logs']
            for dir_name in storage_dirs:
                dir_path = storage_path / dir_name
                if not dir_path.exists():
                    dir_path.mkdir(mode=0o775, parents=True)
                    print(f"Created directory {dir_path}")

        print("\nPermissions setup completed successfully!")
        print("\nNext steps:")
        print("1. Verify the permissions with: ls -la")
        print("2. Test the application to ensure everything works")
        print("3. If using SELinux, you may need to set additional contexts")

    except Exception as e:
        print(f"Error: {str(e)}")
        sys.exit(1)

if __name__ == "__main__":
    main() 