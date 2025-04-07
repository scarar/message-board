<?php

namespace App\Http\Controllers;

use App\Models\Message;
use Illuminate\Http\Request;
use Illuminate\Foundation\Auth\Access\AuthorizesRequests;

class MessageController extends Controller
{
    use AuthorizesRequests;

    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $messages = Message::with('user')->latest()->paginate(10);
        return view('messages.index', compact('messages'));
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        return view('messages.create');
    }

    /**
     * Store a newly created resource in storage.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'youtube_url' => 'nullable|url',
        ]);

        $message = auth()->user()->messages()->create($validated);

        return redirect()->route('messages.show', $message)
            ->with('success', 'Message created successfully!');
    }

    /**
     * Display the specified resource.
     */
    public function show(Message $message)
    {
        return view('messages.show', compact('message'));
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(Message $message)
    {
        $this->authorize('update', $message);
        return view('messages.edit', compact('message'));
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, Message $message)
    {
        $this->authorize('update', $message);

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'youtube_url' => 'nullable|url',
        ]);

        $message->update($validated);

        return redirect()->route('messages.show', $message)
            ->with('success', 'Message updated successfully!');
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(Message $message)
    {
        $this->authorize('delete', $message);
        
        $message->delete();

        return redirect()->route('messages.index')
            ->with('success', 'Message deleted successfully!');
    }
}
