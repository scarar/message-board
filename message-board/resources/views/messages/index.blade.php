@extends('layouts.app')

@section('content')
    <div class="row">
        <div class="col-12">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h1>Messages</h1>
                @auth
                    <a href="{{ route('messages.create') }}" class="btn btn-primary">Create New Message</a>
                @endauth
            </div>

            @if(session('success'))
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    {{ session('success') }}
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            @endif

            <div class="row">
                @foreach($messages as $message)
                    <div class="col-md-6 col-lg-4 mb-4">
                        <div class="card h-100">
                            <div class="card-body">
                                <h5 class="card-title">{{ $message->title }}</h5>
                                <p class="card-text">{{ Str::limit($message->content, 100) }}</p>
                                
                                @if($message->youtube_url)
                                    <div class="ratio ratio-16x9 mb-3">
                                        <iframe 
                                            src="https://www.youtube.com/embed/{{ $message->youtube_id }}"
                                            title="YouTube video player"
                                            frameborder="0"
                                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                            allowfullscreen
                                        ></iframe>
                                    </div>
                                @endif
                                
                                <div class="d-flex justify-content-between align-items-center">
                                    <small class="text-muted">
                                        Posted by {{ $message->user->name }}<br>
                                        <span class="text-muted" title="{{ $message->created_at->format('F j, Y g:i A') }}">
                                            {{ $message->created_at->diffForHumans() }} ({{ $message->created_at->format('M j, g:i A') }})
                                        </span>
                                    </small>
                                    <button type="button" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#messageModal{{ $message->id }}">
                                        Read More
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Modal -->
                    <div class="modal fade" id="messageModal{{ $message->id }}" tabindex="-1" aria-labelledby="messageModalLabel{{ $message->id }}" aria-hidden="true">
                        <div class="modal-dialog modal-lg">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title" id="messageModalLabel{{ $message->id }}">{{ $message->title }}</h5>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                </div>
                                <div class="modal-body">
                                    <p>{{ $message->content }}</p>
                                    
                                    @if($message->youtube_url)
                                        <div class="ratio ratio-16x9 mt-3">
                                            <iframe 
                                                src="https://www.youtube.com/embed/{{ $message->youtube_id }}"
                                                title="YouTube video player"
                                                frameborder="0"
                                                allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                                allowfullscreen
                                            ></iframe>
                                        </div>
                                    @endif
                                    
                                    <div class="mt-3">
                                        <small class="text-muted">
                                            Posted by {{ $message->user->name }}<br>
                                            <span class="text-muted" title="{{ $message->created_at->format('F j, Y g:i A') }}">
                                                {{ $message->created_at->diffForHumans() }} ({{ $message->created_at->format('F j, Y g:i A') }})
                                            </span>
                                            @if($message->created_at != $message->updated_at)
                                                <br>
                                                <span class="text-muted" title="{{ $message->updated_at->format('F j, Y g:i A') }}">
                                                    Last updated: {{ $message->updated_at->diffForHumans() }} ({{ $message->updated_at->format('F j, Y g:i A') }})
                                                </span>
                                            @endif
                                        </small>
                                    </div>
                                </div>
                                <div class="modal-footer">
                                    @can('update', $message)
                                        <a href="{{ route('messages.edit', $message) }}" class="btn btn-primary">Edit</a>
                                        <form action="{{ route('messages.destroy', $message) }}" method="POST" class="d-inline">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-danger">Delete</button>
                                        </form>
                                    @endcan
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                </div>
                            </div>
                        </div>
                    </div>
                @endforeach
            </div>
        </div>
    </div>
@endsection 