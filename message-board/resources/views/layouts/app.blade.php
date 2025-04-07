<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <meta name="csrf-token" content="{{ csrf_token() }}">

        <title>{{ config('app.name', 'Laravel') }}</title>

        <!-- Bootstrap CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        
        <!-- Custom CSS -->
        <style>
            :root {
                --primary-color: #4F46E5;
                --secondary-color: #F3F4F6;
                --accent-color: #10B981;
                --text-color: #1F2937;
                --bg-color: #FFFFFF;
            }
            
            body {
                background-color: var(--bg-color);
                color: var(--text-color);
                min-height: 100vh;
                display: flex;
                flex-direction: column;
            }
            
            .navbar {
                background-color: var(--primary-color);
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            
            .navbar-brand, .nav-link {
                color: white !important;
            }
            
            .card {
                border: none;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
                transition: transform 0.2s;
                background-color: var(--secondary-color);
            }
            
            .card:hover {
                transform: translateY(-2px);
            }
            
            .btn-primary {
                background-color: var(--primary-color);
                border-color: var(--primary-color);
            }
            
            .btn-primary:hover {
                background-color: #4338CA;
                border-color: #4338CA;
            }

            .btn-success {
                background-color: var(--accent-color);
                border-color: var(--accent-color);
            }
            
            .btn-success:hover {
                background-color: #059669;
                border-color: #059669;
            }
            
            .message-content {
                white-space: pre-line;
            }

            footer {
                background-color: var(--primary-color);
                color: white;
                padding: 1rem 0;
                margin-top: auto;
            }

            .footer-content {
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .footer-links a {
                color: white;
                text-decoration: none;
                margin-left: 1rem;
            }

            .footer-links a:hover {
                text-decoration: underline;
            }
        </style>
    </head>
    <body>
        <nav class="navbar navbar-expand-lg navbar-dark mb-4">
            <div class="container">
                <a class="navbar-brand" href="{{ route('welcome') }}">Message Board</a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                    <span class="navbar-toggler-icon"></span>
                </button>
                <div class="collapse navbar-collapse" id="navbarNav">
                    <ul class="navbar-nav me-auto">
                        <li class="nav-item">
                            <a class="nav-link" href="{{ route('messages.index') }}">Messages</a>
                        </li>
                    </ul>
                    <ul class="navbar-nav ms-auto">
                        @auth
                            <li class="nav-item">
                                <span class="nav-link">{{ Auth::user()->name }}</span>
                            </li>
                            <li class="nav-item">
                                <form action="{{ route('logout') }}" method="POST" class="d-inline">
                                    @csrf
                                    <button type="submit" class="nav-link btn btn-link">Logout</button>
                                </form>
                            </li>
                        @else
                            <li class="nav-item">
                                <a class="nav-link" href="{{ route('login') }}">Login</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="{{ route('register') }}">Register</a>
                            </li>
                        @endauth
                    </ul>
                </div>
            </div>
        </nav>

        <main class="container flex-grow-1">
            @if(session('success'))
                <div class="alert alert-success">
                    {{ session('success') }}
                </div>
            @endif
            
            @yield('content')
        </main>

        <footer>
            <div class="container">
                <div class="footer-content">
                    <div class="copyright">
                        &copy; {{ date('Y') }} Message Board. All rights reserved.
                    </div>
                    <div class="footer-links">
                        <a href="{{ route('welcome') }}">Home</a>
                        <a href="{{ route('messages.index') }}">Messages</a>
                        @guest
                            <a href="{{ route('login') }}">Login</a>
                            <a href="{{ route('register') }}">Register</a>
                        @endguest
                    </div>
                </div>
            </div>
        </footer>

        <!-- Bootstrap JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>
