@extends('layouts.app')

@section('content')
    <div class="row">
        <div class="col-12">
            <div class="card">
                <div class="card-header">
                    <h1 class="card-title">{{ $message->title }}</h1>
                </div>
                <div class="card-body">
                    <p class="card-text">{{ $message->content }}</p>
                    
                    @if($message->youtube_url)
                        <div class="mt-4">
                            <div class="ratio ratio-16x9">
                                <iframe 
                                    src="https://www.youtube.com/embed/{{ $message->youtube_id }}"
                                    title="YouTube video player"
                                    frameborder="0"
                                    allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
                                    allowfullscreen
                                ></iframe>
                            </div>
                        </div>
                    @endif
                    
                    <div class="mt-4">
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
                <div class="card-footer">
                    @can('update', $message)
                        <div class="d-flex justify-content-between">
                            <a href="{{ route('messages.edit', $message) }}" class="btn btn-primary">Edit</a>
                            <form action="{{ route('messages.destroy', $message) }}" method="POST" class="d-inline">
                                @csrf
                                @method('DELETE')
                                <button type="submit" class="btn btn-danger">Delete</button>
                            </form>
                        </div>
                    @endcan
                </div>
            </div>
        </div>
    </div>
@endsection 