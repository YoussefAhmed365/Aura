package com.lucasjosino.on_audio_query.controllers

import android.app.Activity
import android.content.ContentResolver
import android.content.Context
import android.database.Cursor
import android.net.Uri
import com.lucasjosino.on_audio_query.PluginProvider
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.mockito.ArgumentMatchers
import org.mockito.Mock
import org.mockito.Mockito
import org.mockito.MockitoAnnotations
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(manifest = Config.NONE)
class PlaylistControllerTest {

    @Mock
    private lateinit var activity: Activity

    @Mock
    private lateinit var context: Context

    @Mock
    private lateinit var contentResolver: ContentResolver

    @Mock
    private lateinit var result: MethodChannel.Result

    @Mock
    private lateinit var cursor: Cursor

    private lateinit var playlistController: PlaylistController

    @Before
    fun setUp() {
        MockitoAnnotations.openMocks(this)

        // Mock PluginProvider
        Mockito.`when`(activity.applicationContext).thenReturn(context)
        PluginProvider.set(activity)

        // Mock Context
        Mockito.`when`(context.contentResolver).thenReturn(contentResolver)
    }

    @Test
    fun moveItemTo_ShouldReturnFalse_WhenPlaylistDoesNotExist() {
        // Arrange
        val playlistId = 123
        val from = 0
        val to = 1

        val methodCall = MethodCall("moveItemTo", mapOf(
            "playlistId" to playlistId,
            "from" to from,
            "to" to to
        ))
        PluginProvider.setCurrentMethod(methodCall, result)

        Mockito.`when`(contentResolver.query(
            ArgumentMatchers.any(),
            ArgumentMatchers.any(),
            ArgumentMatchers.any(),
            ArgumentMatchers.any(),
            ArgumentMatchers.any()
        )).thenReturn(cursor)

        Mockito.`when`(cursor.moveToNext()).thenReturn(false)

        playlistController = PlaylistController()
        val spyController = Mockito.spy(playlistController)

        // Act
        spyController.moveItemTo()

        // Assert
        Mockito.verify(result).success(false)
        Mockito.verify(spyController, Mockito.never()).movePlaylistMember(
            ArgumentMatchers.any(), ArgumentMatchers.anyLong(), ArgumentMatchers.anyInt(), ArgumentMatchers.anyInt()
        )
    }

    @Test
    fun moveItemTo_ShouldMoveItemAndReturnTrue_WhenPlaylistExists() {
        // Arrange
        val playlistId = 123
        val from = 0
        val to = 1

        val methodCall = MethodCall("moveItemTo", mapOf(
            "playlistId" to playlistId,
            "from" to from,
            "to" to to
        ))
        PluginProvider.setCurrentMethod(methodCall, result)

        Mockito.`when`(contentResolver.query(
            ArgumentMatchers.any(),
            ArgumentMatchers.any(),
            ArgumentMatchers.any(),
            ArgumentMatchers.any(),
            ArgumentMatchers.any()
        )).thenReturn(cursor)

        // Mock cursor behavior
        Mockito.`when`(cursor.moveToNext()).thenReturn(true, false)
        Mockito.`when`(cursor.getInt(1)).thenReturn(playlistId) // Column index 1 is _ID

        playlistController = PlaylistController()
        val spyController = Mockito.spy(playlistController)

        // Stub movePlaylistMember
        Mockito.doReturn(true).`when`(spyController).movePlaylistMember(
            ArgumentMatchers.any(), ArgumentMatchers.anyLong(), ArgumentMatchers.anyInt(), ArgumentMatchers.anyInt()
        )

        // Act
        spyController.moveItemTo()

        // Assert
        Mockito.verify(spyController).movePlaylistMember(
            ArgumentMatchers.eq(contentResolver),
            ArgumentMatchers.eq(playlistId.toLong()),
            ArgumentMatchers.eq(from),
            ArgumentMatchers.eq(to)
        )
        Mockito.verify(result).success(true)
    }
}
