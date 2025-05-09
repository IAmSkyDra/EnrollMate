<script lang="ts">
	import { onMount } from "svelte";
	import Modal from "$lib/components/Modal.svelte";
	import CarbonClose from "~icons/carbon/close";
	import CarbonTrashCan from "~icons/carbon/trash-can";
	import CarbonArrowUpRight from "~icons/carbon/arrow-up-right";

	import { enhance } from "$app/forms";
	import { base } from "$app/paths";

	import { useSettingsStore } from "$lib/stores/settings";
	import Switch from "$lib/components/Switch.svelte";
	import { env as envPublic } from "$env/dynamic/public";
	import i18n from "$lib/i18n";
	import { getLanguages } from "$lib/i18n";

	let isConfirmingDeletion = $state(false);
	let languages = $state({});

	let settings = useSettingsStore();

	onMount(async () => {
		languages = await getLanguages();
	});

	function handleLanguageChange(event: Event) {
		const select = event.target as HTMLSelectElement;
		$i18n.changeLanguage(select.value);
		localStorage.setItem('locale', select.value);
	}
</script>

<div class="flex w-full flex-col gap-5">
	<div class="flex flex-col items-start justify-between text-xl font-semibold text-gray-800">
		<h2>{$i18n.t('settings.title')}</h2>
		{#if !!envPublic.PUBLIC_COMMIT_SHA}
			<a
				href={`https://github.com/huggingface/chat-ui/commit/${envPublic.PUBLIC_COMMIT_SHA}`}
				target="_blank"
				rel="noreferrer"
				class="text-sm font-light text-gray-500"
			>
				{$i18n.t('settings.latest_deployment')} <span class="gap-2 font-mono"
					>{envPublic.PUBLIC_COMMIT_SHA.slice(0, 7)}</span
				>
			</a>
		{/if}
	</div>
	<div class="flex h-full max-w-2xl flex-col gap-2 max-sm:pt-0">
		<!-- Language Selection -->
		<div class="mb-6">
			<label class="flex flex-col gap-2">
				<span class="font-semibold">{$i18n.t('settings.language')}</span>
				<p class="text-sm text-gray-500">{$i18n.t('settings.language_description')}</p>
				<select
					class="w-full max-w-xs rounded-lg border border-gray-300 px-4 py-2"
					onchange={handleLanguageChange}
					value={$i18n.language}
				>
					{#each Object.entries(languages) as [code, name]}
						<option value={code}>{name}</option>
					{/each}
				</select>
			</label>
		</div>

		{#if envPublic.PUBLIC_APP_DATA_SHARING === "1"}
			<label class="flex items-center">
				<Switch
					name="shareConversationsWithModelAuthors"
					bind:checked={$settings.shareConversationsWithModelAuthors}
				/>
				<div class="inline cursor-pointer select-none items-center gap-2 pl-2">
					{$i18n.t('settings.share_conversations')}
				</div>
			</label>

			<p class="text-sm text-gray-500">
				{$i18n.t('settings.share_conversations_description')}
			</p>
		{/if}
		<label class="mt-6 flex items-center">
			<Switch name="hideEmojiOnSidebar" bind:checked={$settings.hideEmojiOnSidebar} />
			<div class="inline cursor-pointer select-none items-center gap-2 pl-2 font-semibold">
				{$i18n.t('settings.hide_emoji')}
				<p class="text-sm font-normal text-gray-500">
					{$i18n.t('settings.hide_emoji_description')}
				</p>
			</div>
		</label>

		<label class="mt-6 flex items-center">
			<Switch name="disableStream" bind:checked={$settings.disableStream} />
			<div class="inline cursor-pointer select-none items-center gap-2 pl-2 font-semibold">
				{$i18n.t('settings.disable_stream')}
			</div>
		</label>

		<label class="mt-6 flex items-center">
			<Switch name="directPaste" bind:checked={$settings.directPaste} />
			<div class="inline cursor-pointer select-none items-center gap-2 pl-2 font-semibold">
				{$i18n.t('settings.direct_paste')}
				<p class="text-sm font-normal text-gray-500">
					{$i18n.t('settings.direct_paste_description')}
				</p>
			</div>
		</label>

		<div class="mt-12 flex flex-col gap-3">
			<a
				href="https://huggingface.co/spaces/huggingchat/chat-ui/discussions"
				target="_blank"
				rel="noreferrer"
				class="flex items-center underline decoration-gray-300 underline-offset-2 hover:decoration-gray-700"
				><CarbonArrowUpRight class="mr-1.5 shrink-0 text-sm " /> {$i18n.t('settings.share_feedback')}</a
			>
			<button
				onclick={(e) => {
					e.preventDefault();
					isConfirmingDeletion = true;
				}}
				type="submit"
				class="flex items-center underline decoration-gray-300 underline-offset-2 hover:decoration-gray-700"
				><CarbonTrashCan class="mr-2 inline text-sm text-red-500" />{$i18n.t('settings.delete_all')}</button
			>
		</div>
	</div>

	{#if isConfirmingDeletion}
		<Modal on:close={() => (isConfirmingDeletion = false)}>
			<form
				use:enhance={() => {
					isConfirmingDeletion = false;
				}}
				method="post"
				action="{base}/conversations?/delete"
				class="flex w-full flex-col gap-5 p-6"
			>
				<div class="flex items-start justify-between text-xl font-semibold text-gray-800">
					<h2>{$i18n.t('settings.delete_confirm_title')}</h2>
					<button
						type="button"
						class="group"
						onclick={(e) => {
							e.stopPropagation();
							isConfirmingDeletion = false;
						}}
					>
						<CarbonClose class="text-gray-900 group-hover:text-gray-500" />
					</button>
				</div>
				<p class="text-gray-800">
					{$i18n.t('settings.delete_confirm_description')}
				</p>
				<button
					type="submit"
					class="mt-2 rounded-full bg-red-700 px-5 py-2 text-lg font-semibold text-gray-100 ring-gray-400 ring-offset-1 transition-all hover:ring focus-visible:outline-none focus-visible:ring"
				>
					{$i18n.t('settings.delete_confirm_button')}
				</button>
			</form>
		</Modal>
	{/if}
</div>
